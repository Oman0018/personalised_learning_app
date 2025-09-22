# backend/models/clustering.py

import joblib
import os
import logging

# Enable logging
logging.basicConfig(level=logging.INFO)

MODEL_PATH = os.path.join(os.path.dirname(__file__), "clustering_model.pkl")

def load_clustering_model():
    """
    Load the clustering model from file.
    Raises FileNotFoundError if model file does not exist.
    """
    if not os.path.exists(MODEL_PATH):
        logging.error(f"Clustering model file not found at {MODEL_PATH}")
        raise FileNotFoundError(f"Clustering model not found at: {MODEL_PATH}")
    
    logging.info(f"Loading clustering model from: {MODEL_PATH}")
    return joblib.load(MODEL_PATH)

def assign_cluster(model, user_input):
    """
    Assign a user to a cluster group based on features.
    Input: user_input - list of 4 numerical features
    Returns: cluster number (int)
    """
    cluster = model.predict([user_input])[0]
    logging.info(f"User assigned to cluster: {cluster}")
    return cluster

def assign_clusters_batch(model, input_list):
    """
    Assign clusters to a batch of users.
    Input: input_list - list of feature vectors
    Returns: list of cluster indices
    """
    clusters = model.predict(input_list).tolist()
    logging.info(f"Batch clusters assigned: {clusters}")
    return clusters
