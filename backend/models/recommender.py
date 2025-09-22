# backend/models/recommender.py

import joblib
import os
import logging

# Set up basic logging
logging.basicConfig(level=logging.INFO)

MODEL_PATH = os.path.join(os.path.dirname(__file__), "recommendation_model.pkl")

def load_recommendation_model():
    """
    Loads the trained recommendation model.
    Raises an error if the model file is missing.
    """
    if not os.path.exists(MODEL_PATH):
        logging.error(f"Model file not found at {MODEL_PATH}")
        raise FileNotFoundError(f"Model not found at: {MODEL_PATH}")
    
    logging.info(f"Loading recommendation model from: {MODEL_PATH}")
    return joblib.load(MODEL_PATH)

def recommend_topic(model, user_input):
    """
    Predict a single learning topic based on user input.
    user_input: list of 4 features
    Returns: topic name as string
    """
    prediction = model.predict([user_input])
    topic_mapping = {
        0: "Artificial Intelligence",
        1: "Web Development",
        2: "Data Science"
    }
    result = topic_mapping.get(prediction[0], "Unknown Topic")
    logging.info(f"Predicted topic index: {prediction[0]} -> {result}")
    return result

def recommend_topics_batch(model, input_list):
    """
    Predict topics for a batch of user input vectors.
    input_list: list of lists, each with 4 features
    Returns: list of topic names
    """
    predictions = model.predict(input_list)
    topic_mapping = {
        0: "Artificial Intelligence",
        1: "Web Development",
        2: "Data Science"
    }
    return [topic_mapping.get(pred, "Unknown Topic") for pred in predictions]
