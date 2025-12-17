"""
API tests for playlist generation endpoint.

H3: Unit Test Creation - API endpoint tests.
C2: Regression Prevention - Run all tests before committing.
"""
import pytest
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


class TestPlaylistAPI:
    """Tests for /api/playlist/generate endpoint."""
    
    def test_valid_playlist_generation(self):
        """Should generate playlist for valid request."""
        request = {
            "birth_datetime": "1990-06-15T14:30:00",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "timezone": "America/New_York",
            "playlist_size": 20
        }
        
        response = client.post("/api/playlist/generate", json=request)
        
        assert response.status_code == 200
        data = response.json()
        
        # Verify response structure
        assert "songs" in data
        assert "total_duration_seconds" in data
        assert "vibe_match_score" in data
        assert "energy_arc" in data
        assert "element_distribution" in data
        assert "mood_distribution" in data
        assert "generation_metadata" in data
        
        # Verify computed fields
        assert "duration_minutes" in data
        assert "song_count" in data
        
        # Verify playlist size
        assert len(data["songs"]) <= 20
        assert data["song_count"] == len(data["songs"])
    
    def test_invalid_datetime_format(self):
        """Should return 422 for invalid datetime format (Pydantic validation)."""
        request = {
            "birth_datetime": "not-a-datetime",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "playlist_size": 20
        }
        
        response = client.post("/api/playlist/generate", json=request)
        
        # Pydantic validates datetime format and returns 422
        assert response.status_code == 422
        assert "detail" in response.json()
    
    def test_invalid_latitude(self):
        """Should return 422 for out-of-range latitude."""
        request = {
            "birth_datetime": "1990-06-15T14:30:00",
            "latitude": 200,  # Invalid
            "longitude": -74.0060,
            "playlist_size": 20
        }
        
        response = client.post("/api/playlist/generate", json=request)
        
        # Pydantic validation should catch this
        assert response.status_code == 422
    
    def test_invalid_longitude(self):
        """Should return 422 for out-of-range longitude."""
        request = {
            "birth_datetime": "1990-06-15T14:30:00",
            "latitude": 40.7128,
            "longitude": -200,  # Invalid
            "playlist_size": 20
        }
        
        response = client.post("/api/playlist/generate", json=request)
        
        assert response.status_code == 422
    
    def test_playlist_size_validation(self):
        """Should enforce playlist_size range (10-30)."""
        # Test below minimum
        request = {
            "birth_datetime": "1990-06-15T14:30:00",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "playlist_size": 5  # Below minimum
        }
        
        response = client.post("/api/playlist/generate", json=request)
        assert response.status_code == 422
        
        # Test above maximum
        request["playlist_size"] = 50  # Above maximum
        response = client.post("/api/playlist/generate", json=request)
        assert response.status_code == 422
        
        # Test valid range
        for size in [10, 20, 30]:
            request["playlist_size"] = size
            response = client.post("/api/playlist/generate", json=request)
            assert response.status_code == 200
    
    def test_optional_current_datetime(self):
        """Should accept optional current_datetime."""
        request = {
            "birth_datetime": "1990-06-15T14:30:00",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "playlist_size": 15,
            "current_datetime": "2024-12-16T15:00:00"
        }
        
        response = client.post("/api/playlist/generate", json=request)
        
        assert response.status_code == 200
        data = response.json()
        assert len(data["songs"]) <= 15
    
    def test_optional_current_location(self):
        """Should accept optional current location."""
        request = {
            "birth_datetime": "1990-06-15T14:30:00",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "playlist_size": 20,
            "current_latitude": 34.0522,  # Los Angeles
            "current_longitude": -118.2437
        }
        
        response = client.post("/api/playlist/generate", json=request)
        
        assert response.status_code == 200
    
    def test_response_structure_matches_model(self):
        """Response should match PlaylistResult model structure."""
        request = {
            "birth_datetime": "1990-06-15T14:30:00",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "playlist_size": 10
        }
        
        response = client.post("/api/playlist/generate", json=request)
        
        assert response.status_code == 200
        data = response.json()
        
        # Check all songs have required fields
        for song in data["songs"]:
            assert "id" in song
            assert "title" in song
            assert "artist" in song
            assert "energy" in song
            assert "valence" in song
            assert "genres" in song
            assert "moods" in song
        
        # Check energy arc length matches songs
        assert len(data["energy_arc"]) == len(data["songs"])
        
        # Check vibe_match_score is in range
        assert 0 <= data["vibe_match_score"] <= 100
    
    def test_invalid_timezone(self):
        """Should return 400 for invalid timezone."""
        request = {
            "birth_datetime": "1990-06-15T14:30:00",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "timezone": "Invalid/Timezone",
            "playlist_size": 20
        }
        
        response = client.post("/api/playlist/generate", json=request)
        
        assert response.status_code == 400
        assert "timezone" in response.json()["detail"].lower()
    
    def test_minimal_valid_request(self):
        """Should work with minimal required fields."""
        request = {
            "birth_datetime": "1990-06-15T14:30:00",
            "latitude": 40.7128,
            "longitude": -74.0060
            # Uses defaults: timezone="UTC", playlist_size=20
        }
        
        response = client.post("/api/playlist/generate", json=request)
        
        assert response.status_code == 200
        data = response.json()
        assert len(data["songs"]) <= 20  # Default size
