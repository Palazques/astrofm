from models.schemas import DailyReadingRequest
from pydantic import ValidationError

data = {
    "datetime": "1990-07-15T15:42:00",
    "latitude": 34.0522,
    "longitude": -118.2437,
    "timezone": "America/Los_Angeles"
}

try:
    model = DailyReadingRequest(**data)
    print("Validation successful!")
    print(model.model_dump())
except ValidationError as e:
    print("Validation failed!")
    print(e)
