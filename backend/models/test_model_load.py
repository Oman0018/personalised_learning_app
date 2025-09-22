import joblib
import os

def test_recommendation_model():
    path = os.path.join(os.path.dirname(__file__), "recommendation_model.pkl")
    model = joblib.load(path)
    assert model is not None, "❌ Recommendation model failed to load!"
    print("✅ Recommendation model loaded successfully!")

def test_clustering_model():
    path = os.path.join(os.path.dirname(__file__), "clustering_model.pkl")
    model = joblib.load(path)
    assert model is not None, "❌ Clustering model failed to load!"
    print("✅ Clustering model loaded successfully!")

if __name__ == "__main__":
    test_recommendation_model()
    test_clustering_model()
