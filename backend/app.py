# backend/app.py
from __future__ import annotations

import logging
import os
from pathlib import Path
from statistics import mean
from typing import Any, Dict, Optional, Tuple, List

from flask import Flask, request, jsonify
from flask_cors import CORS

# ------------------------------------------------------------------------------
# Env + logging
# ------------------------------------------------------------------------------
from dotenv import load_dotenv
load_dotenv(dotenv_path=Path(__file__).parent / ".env")

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

# ------------------------------------------------------------------------------
# Optional Gemini (safe if not configured)
# ------------------------------------------------------------------------------
def _env_bool(name: str, default: bool) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    return str(raw).strip().lower() in ("1", "true", "yes", "y", "on")

GEMINI_EXPLICIT_ENABLED = _env_bool("GEMINI_ENABLED", True)
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "").strip()
USE_GEMINI = GEMINI_EXPLICIT_ENABLED and bool(GEMINI_API_KEY)

GEMINI_MODEL_ENV = os.getenv("GEMINI_MODEL", "").strip()
GEMINI_DEFAULT = "gemini-2.5-flash"

_fallbacks_env = os.getenv("GEMINI_FALLBACKS", "").strip()
if _fallbacks_env:
    GEMINI_FALLBACKS: List[str] = [m.strip() for m in _fallbacks_env.split(",") if m.strip()]
else:
    GEMINI_FALLBACKS = ["gemini-2.5-pro", "gemini-1.5-pro", "gemini-1.5-flash"]

def _env_float(name: str, default: Optional[float]) -> Optional[float]:
    v = os.getenv(name)
    if v is None or v == "":
        return default
    try:
        return float(v)
    except ValueError:
        log.warning("Invalid %s=%r; using default %s", name, v, default)
        return default

GEMINI_TEMPERATURE = _env_float("GEMINI_TEMPERATURE", 0.2)
GEMINI_MAX_TOKENS  = int(_env_float("GEMINI_MAX_TOKENS", 256) or 256)
GEMINI_TOP_P       = _env_float("GEMINI_TOP_P", None)
GEMINI_TOP_K       = int(_env_float("GEMINI_TOP_K", 32) or 32)
GEMINI_TIMEOUT_S   = int(_env_float("GEMINI_TIMEOUT_S", 15) or 15)
GEMINI_SYSTEM_PROMPT = os.getenv("GEMINI_SYSTEM_PROMPT", "").strip() or None

log.info("Gemini enabled: %s", USE_GEMINI)

_gemini_client: Any = None
if USE_GEMINI:
    try:
        from google import genai  # pip install google-genai
        _gemini_client = genai.Client(api_key=GEMINI_API_KEY)
    except Exception:
        log.exception("Gemini init failed; disabling Gemini.")
        USE_GEMINI = False


def _compose_prompt(user_text: str) -> str:
    if GEMINI_SYSTEM_PROMPT:
        return f"{GEMINI_SYSTEM_PROMPT.strip()}\n\n{user_text}"
    return user_text


def _gemini_generate(text: str) -> Optional[str]:
    """Call Gemini with model fallback. Returns None on failure."""
    if not USE_GEMINI or not _gemini_client:
        return None

    # Order of models to try
    models_to_try: List[str] = []
    if GEMINI_MODEL_ENV:
        models_to_try.append(GEMINI_MODEL_ENV)
    if GEMINI_DEFAULT and GEMINI_DEFAULT not in models_to_try:
        models_to_try.append(GEMINI_DEFAULT)
    for m in GEMINI_FALLBACKS:
        if m not in models_to_try:
            models_to_try.append(m)

    # Generation config – keep as Any to appease Pylance
    gen_cfg: Any = {"max_output_tokens": GEMINI_MAX_TOKENS}
    if GEMINI_TEMPERATURE is not None:
        gen_cfg["temperature"] = GEMINI_TEMPERATURE
    if GEMINI_TOP_P is not None:
        gen_cfg["top_p"] = GEMINI_TOP_P
    if GEMINI_TOP_K is not None:
        gen_cfg["top_k"] = GEMINI_TOP_K

    tried = []
    contents = _compose_prompt(text)

    # Treat the callable as Any so static checker doesn’t enforce arg names
    gc: Any = getattr(_gemini_client.models, "generate_content")

    for model in models_to_try:
        try:
            # Prefer new signature: config=...
            try:
                resp = gc(model=model, contents=contents, config=gen_cfg)
            except TypeError:
                # Fallback for older client: generation_config=...
                resp = gc(model=model, contents=contents, **{"generation_config": gen_cfg})

            out = (getattr(resp, "text", None) or "").strip()
            if out:
                log.info("Gemini OK using model=%s (chars=%s)", model, len(out))
                return out
            else:
                log.warning("Gemini empty text using model=%s; trying next…", model)
                tried.append((model, "empty response"))
        except Exception as e:
            emsg = str(e)
            tried.append((model, emsg))
            if "404" in emsg or "not found" in emsg.lower():
                log.warning("Gemini model not found: %s; trying next…", model)
                continue
            log.exception("Gemini generate failed (model=%s)", model)
            return None

    log.error("Gemini failed across models: %s", tried)
    return None


# ------------------------------------------------------------------------------
# Local model imports
# ------------------------------------------------------------------------------
from models.recommender import load_recommendation_model, recommend_topic
from models.clustering import load_clustering_model, assign_cluster

# ------------------------------------------------------------------------------
# App & CORS
# ------------------------------------------------------------------------------
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# ------------------------------------------------------------------------------
# Models: load once at startup
# ------------------------------------------------------------------------------
recommendation_model = load_recommendation_model()
clustering_model = load_clustering_model()

# ------------------------------------------------------------------------------
# Helpers: coercion + validation
# ------------------------------------------------------------------------------
CONTENT_STR_TO_CODE = {"video": 0, "text": 1, "interactive": 2}
CONTENT_CODE_TO_STR = {v: k for k, v in CONTENT_STR_TO_CODE.items()}

FIELD_ALIASES = {
    "avg_quiz_score": ("avg_quiz_score", "quiz_score", "score"),
    "avg_time_spent": ("avg_time_spent", "time_spent", "duration"),
    "content_type_pref": ("content_type_pref", "content_type", "format", "contentPreference"),
    "topic_engagement": ("topic_engagement", "engagement", "likert", "interest"),
    "last_topic": ("last_topic", "previous_topic"),
}

def _find_key(data: Dict[str, Any], *candidates: str) -> Optional[str]:
    for k in candidates:
        if k in data:
            return k
    return None

def _to_float(x: Any, field: str) -> float:
    try:
        if isinstance(x, bool):
            raise ValueError
        return float(x)
    except Exception as e:
        raise ValueError(f"Field '{field}' must be numeric; got {type(x).__name__}.") from e

def _norm_engagement(value: Any) -> float:
    """Accept 0..1 or 1..5 Likert; list/dict are averaged; returns 0..1."""
    if isinstance(value, dict):
        vals = [float(v) for v in value.values()]
        value = mean(vals) if vals else 0.0
    elif isinstance(value, (list, tuple)):
        vals = [float(v) for v in value]
        value = mean(vals) if vals else 0.0

    val = _to_float(value, "topic_engagement")
    if val > 1.0:
        val = max(1.0, min(val, 5.0)) / 5.0
    else:
        val = max(0.0, min(val, 1.0))
    return float(val)

def _coerce_content_type_pref(value: Any) -> Tuple[float, str]:
    """Accept 'Video'/'Text'/'Interactive' OR 0/1/2 OR 1/2/3."""
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        n = int(value)
        code = n - 1 if n in (1, 2, 3) else n
        if code not in CONTENT_CODE_TO_STR:
            code = 0
        return float(code), CONTENT_CODE_TO_STR[code]

    s = str(value).strip().lower()
    if s in CONTENT_STR_TO_CODE:
        code = CONTENT_STR_TO_CODE[s]
        return float(code), s

    code = int(_to_float(value, "content_type_pref"))
    code = code - 1 if code in (1, 2, 3) else code
    if code not in CONTENT_CODE_TO_STR:
        code = 0
    return float(code), CONTENT_CODE_TO_STR[code]

def _parse_payload(data: Dict[str, Any]) -> Tuple[List[float], Dict[str, Any]]:
    """Return (features_for_model, normalized_view_for_response)."""
    if not isinstance(data, dict):
        raise ValueError("Body must be a JSON object.")

    k_quiz = _find_key(data, *FIELD_ALIASES["avg_quiz_score"])
    k_time = _find_key(data, *FIELD_ALIASES["avg_time_spent"])
    k_ct   = _find_key(data, *FIELD_ALIASES["content_type_pref"])
    k_eng  = _find_key(data, *FIELD_ALIASES["topic_engagement"])
    k_last = _find_key(data, *FIELD_ALIASES["last_topic"])

    if k_quiz is None or k_time is None or k_ct is None or k_eng is None:
        missing = []
        if k_quiz is None: missing.append("avg_quiz_score")
        if k_time is None: missing.append("avg_time_spent")
        if k_ct   is None: missing.append("content_type_pref")
        if k_eng  is None: missing.append("topic_engagement")
        raise ValueError(f"Missing field(s): {', '.join(missing)}")

    kq: str = k_quiz
    kt: str = k_time
    kct: str = k_ct
    ke: str = k_eng

    quiz = _to_float(data[kq], "avg_quiz_score")
    time_spent = _to_float(data[kt], "avg_time_spent")
    ct_code, ct_str = _coerce_content_type_pref(data[kct])
    engagement = _norm_engagement(data[ke])

    last_topic_raw = data.get(k_last) if k_last is not None else None
    last_topic = str(last_topic_raw) if last_topic_raw is not None else ""

    features: List[float] = [quiz, time_spent, ct_code, engagement]
    normalized: Dict[str, Any] = {
        "avg_quiz_score": float(quiz),
        "avg_time_spent": float(time_spent),
        "content_type": ct_str,
        "topic_engagement": float(engagement),
        "last_topic": last_topic or None,
    }
    return features, normalized

# ------------------------------------------------------------------------------
# v2 helpers (non-breaking add-on)
# ------------------------------------------------------------------------------
def _rule_next_content(quiz_score: float, time_spent: float, engagement_0_1: float) -> str:
    if engagement_0_1 <= 0.4:
        return "interactive"
    if time_spent < 20:
        return "text"
    if quiz_score >= 75:
        return "video"
    return "text"

_DAG = {
    "Foundations": ["Data Types & Variables"],
    "Data Types & Variables": ["Control Flow & Loops"],
    "Control Flow & Loops": ["Functions & Modularisation"],
    "Functions & Modularisation": [],
}

def _next_topic_dag(last_topic: str, fallback_topic: str) -> str:
    nxt = _DAG.get((last_topic or "Foundations"), [])
    return nxt[0] if nxt else fallback_topic

def _gemini_explain(topic: str, profile: str, content_type: str,
                    quiz_score: float, time_spent: float, engagement_0_1: float) -> Optional[str]:
    if not USE_GEMINI:
        return None
    prompt = (
        f"You are a study coach.\n"
        f"Profile: {profile}. Topic: {topic}. Chosen content: {content_type}.\n"
        f"Signals: quiz_score={quiz_score}, time_spent={time_spent} mins, engagement={engagement_0_1}/1.\n"
        f"Reply in <=80 words explaining why this step fits and give 1 micro tip."
    )
    return _gemini_generate(prompt)

def _build_response(user_features: List[float], normalized: Dict[str, Any], last_topic: Optional[str]) -> Dict[str, Any]:
    quiz, time_spent, _, engagement = user_features

    topic_v1 = recommend_topic(recommendation_model, user_features)
    cluster = assign_cluster(clustering_model, user_features)

    next_format = _rule_next_content(quiz, time_spent, engagement)
    topic = _next_topic_dag(last_topic or "Foundations", topic_v1)

    profile = f"Cluster {int(cluster)}"
    rationale = f"{profile} \u2192 {topic}; signals favour {next_format}. (Built on v1 models)"

    gemini_text = _gemini_explain(topic, profile, next_format,
                                  quiz_score=quiz, time_spent=time_spent, engagement_0_1=engagement)

    log.info("INFER topic=%s cluster=%s format=%s features=%s", topic, cluster, next_format, user_features)

    return {
        "status": "success",
        "recommended_topic": topic,
        "content_type": next_format,
        "user_cluster": int(cluster),
        "rationale": rationale,
        "gemini_note": gemini_text
    }

# ------------------------------------------------------------------------------
# Routes
# ------------------------------------------------------------------------------
@app.get("/")
def home():
    return "✅ Personalised Learning Pathway API is running!", 200

@app.get("/health")
@app.get("/healthz")
def health():
    return jsonify(status="ok"), 200

@app.get("/favicon.ico")
def favicon():
    return ("", 204)

@app.get("/recommend")
def recommend_get_help():
    return jsonify(
        info="POST JSON to this endpoint.",
        sample_payload={
            "avg_quiz_score": 72,
            "avg_time_spent": 30,
            "content_type_pref": "Video",
            "topic_engagement": 4,
            "last_topic": "Foundations"
        }
    ), 200

@app.post("/recommend")
def recommend():
    data = request.get_json(silent=True) or {}
    try:
        feats, norm = _parse_payload(data)
        resp = _build_response(feats, norm, norm.get("last_topic"))
        return jsonify(resp), 200
    except ValueError as ve:
        log.info("400 /recommend - bad payload: %s | error=%s", data, ve)
        return jsonify(error=str(ve), status="failed"), 400
    except Exception:
        log.exception("500 /recommend - inference failed")
        return jsonify(error="inference_failed", status="failed"), 500

@app.post("/recommend/v2")
def recommend_v2():
    data = request.get_json(silent=True) or {}
    try:
        feats, norm = _parse_payload(data)
        resp = _build_response(feats, norm, norm.get("last_topic"))
        return jsonify(resp), 200
    except ValueError as ve:
        log.info("400 /recommend/v2 - bad payload: %s | error=%s", data, ve)
        return jsonify(error=str(ve), status="failed"), 400
    except Exception:
        log.exception("500 /recommend/v2 - inference failed")
        return jsonify(error="inference_failed", status="failed"), 500

@app.get("/recommend/v2/demo")
def recommend_v2_demo():
    payload = {
        "avg_quiz_score": 72,
        "avg_time_spent": 15,
        "content_type_pref": "video",
        "topic_engagement": 3,
        "last_topic": "Foundations",
    }
    try:
        feats, norm = _parse_payload(payload)
        resp = _build_response(feats, norm, norm.get("last_topic"))
        return jsonify(resp), 200
    except Exception:
        log.exception("500 /recommend/v2/demo - failed")
        return jsonify(error="inference_failed", status="failed"), 500

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
