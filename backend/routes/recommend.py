from flask import Blueprint, request, jsonify
from models.recommender import load_recommendation_model, recommend_topic

recommend_route = Blueprint("recommend_route", __name__)
model = load_recommendation_model()

@recommend_route.route("/recommend", methods=["POST"])
def recommend():
    data = request.get_json()

    try:
        user_input = [
            data["avg_quiz_score"],
            data["avg_time_spent"],
            data["content_type_pref"],
            data["topic_engagement"]
        ]

        topic = recommend_topic(model, user_input)
        return jsonify({"recommended_topic": topic})

    except KeyError as e:
        return jsonify({"error": f"Missing field: {str(e)}"}), 400
