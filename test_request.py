import requests

url = "http://127.0.0.1:5000/recommend"
payload = {
    "avg_quiz_score": 75,
    "avg_time_spent": 30,
    "content_type_pref": 1,
    "topic_engagement": 4
}

response = requests.post(url, json=payload)
print(response.status_code)
print(response.json())
