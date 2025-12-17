import requests
import sys

data = {
    "datetime": "1990-07-15T15:42:00",
    "latitude": 34.0522,
    "longitude": -118.2437,
    "timezone": "America/Los_Angeles"
}

try:
    print("Sending request...")
    r = requests.post(
        'http://localhost:8000/api/ai/daily-reading', 
        json=data,
        timeout=10
    )
    print(f"Status: {r.status_code}")
    print(f"Response: {r.text}")
except Exception as e:
    print(f"Error: {e}")
