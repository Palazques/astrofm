"""
Geocoding API routes.
"""
from fastapi import APIRouter, Query

from services.geocoding import search_locations, LocationResult

router = APIRouter(prefix="/api/geocode", tags=["geocoding"])


@router.get("/search", response_model=list[LocationResult])
async def geocode_search(
    query: str = Query(..., min_length=2, description="Location search query"),
    limit: int = Query(5, ge=1, le=10, description="Maximum results to return")
) -> list[LocationResult]:
    """
    Search for locations by name.
    
    Returns a list of matching locations with coordinates.
    Supports cities, addresses, and landmarks worldwide.
    
    Args:
        query: Search text (e.g., "Los Angeles", "Tokyo", "Paris")
        limit: Maximum number of results (1-10)
        
    Returns:
        List of locations with display name, coordinates, and address components
    """
    return search_locations(query, limit)
