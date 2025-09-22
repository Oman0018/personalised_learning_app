import joblib
from sklearn.tree import DecisionTreeClassifier
from sklearn.cluster import KMeans
import numpy as np
import os

# Define output directory
output_dir = os.path.join("backend", "models")

# Create directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# Dummy data (X) and labels (y)
X = np.array([
    [80, 25, 0, 4],
    [60, 30, 1, 3],
    [90, 20, 0, 5],
    [50, 40, 2, 2],
    [70, 35, 1, 3]
])
y = np.array([0, 1, 0, 2, 1])  # 0=AI, 1=Web Dev, 2=Data Science

# Recommendation model (Decision Tree)
recommendation_model = DecisionTreeClassifier()
recommendation_model.fit(X, y)
joblib.dump(recommendation_model, os.path.join(output_dir, "recommendation_model.pkl"))

# Clustering model (KMeans)
clustering_model = KMeans(n_clusters=3, random_state=42)
clustering_model.fit(X)
joblib.dump(clustering_model, os.path.join(output_dir, "clustering_model.pkl"))

print("✅ Dummy models saved successfully to:", output_dir)
