"""
Geocoding service using OpenStreetMap Nominatim.
Provides location search with autocomplete functionality.
"""
from typing import Optional
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError
from pydantic import BaseModel, Field
import time

# Rate limiting: Nominatim requires max 1 request per second
_last_request_time = 0.0
_MIN_REQUEST_INTERVAL = 1.0  # seconds


class LocationResult(BaseModel):
    """Model for a geocoding result."""
    display_name: str = Field(..., description="Full formatted address")
    city: Optional[str] = Field(None, description="City name")
    state: Optional[str] = Field(None, description="State/Region name")
    country: str = Field(..., description="Country name")
    country_code: str = Field(..., description="ISO country code")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")


# Initialize geocoder with a user agent (required by Nominatim)
_geocoder = Nominatim(user_agent="astrofm_app/1.0")


def _rate_limit():
    """Enforce rate limiting for Nominatim API."""
    global _last_request_time
    current_time = time.time()
    elapsed = current_time - _last_request_time
    if elapsed < _MIN_REQUEST_INTERVAL:
        time.sleep(_MIN_REQUEST_INTERVAL - elapsed)
    _last_request_time = time.time()


def _extract_location_parts(raw: dict) -> dict:
    """
    Extract city, state, country from Nominatim raw response.
    Handles different address formats for various countries.
    """
    address = raw.get("address", {})
    
    # City: try multiple fields (different countries use different fields)
    city = (
        address.get("city") or
        address.get("town") or
        address.get("village") or
        address.get("municipality") or
        address.get("hamlet") or
        address.get("suburb") or
        None
    )
    
    # State/Region: varies by country
    state = (
        address.get("state") or
        address.get("province") or
        address.get("region") or
        address.get("county") or
        address.get("state_district") or
        None
    )
    
    # Country
    country = address.get("country", "Unknown")
    country_code = address.get("country_code", "").upper()
    
    return {
        "city": city,
        "state": state,
        "country": country,
        "country_code": country_code,
    }


def _format_display_name(city: Optional[str], state: Optional[str], country: str) -> str:
    """Format location for display."""
    parts = []
    if city:
        parts.append(city)
    if state:
        parts.append(state)
    parts.append(country)
    return ", ".join(parts)


def search_locations(query: str, limit: int = 5) -> list[LocationResult]:
    """
    Search for locations matching the query.
    
    Args:
        query: Search query (city name, address, etc.)
        limit: Maximum number of results to return
        
    Returns:
        List of LocationResult objects
    """
    if not query or len(query) < 2:
        return []
    
    _rate_limit()
    
    try:
        # Search with detailed address info
        results = _geocoder.geocode(
            query,
            exactly_one=False,
            limit=limit,
            addressdetails=True,
            language="en"
        )
        
        if not results:
            return []
        
        locations = []
        for result in results:
            raw = result.raw
            parts = _extract_location_parts(raw)
            
            # Create formatted display name
            display_name = _format_display_name(
                parts["city"],
                parts["state"],
                parts["country"]
            )
            
            locations.append(LocationResult(
                display_name=display_name,
                city=parts["city"],
                state=parts["state"],
                country=parts["country"],
                country_code=parts["country_code"],
                latitude=result.latitude,
                longitude=result.longitude,
            ))
        
        return locations
        
    except GeocoderTimedOut:
        print("Geocoding request timed out")
        return []
    except GeocoderServiceError as e:
        print(f"Geocoding service error: {e}")
        return []
    except Exception as e:
        print(f"Geocoding error: {e}")
        return []
