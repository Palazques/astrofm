"""
Discover API routes for event discovery with astrological alignment.

S2: Documentation Rule - All endpoints include clear docstrings.
"""
from fastapi import APIRouter, HTTPException, Query, Body
from typing import List, Optional

from services.event_service import (
    EventService, 
    Event, 
    CreateEventRequest,
    EventType,
    EVENT_TYPE_ICONS,
    EVENT_TYPE_ELEMENTS,
)
from services.seasonal_guidance import get_seasonal_guidance, SeasonalGuidance

router = APIRouter(prefix="/api/discover", tags=["discover"])
event_service = EventService()


@router.get("/seasonal-guidance", response_model=SeasonalGuidance)
async def get_current_seasonal_guidance():
    """
    Get current zodiac season guidance for the Discover page.
    
    Returns:
        SeasonalGuidance with sign, element, guidance text, and recommended event types
    """
    try:
        return get_seasonal_guidance()
    except Exception as e:
        print(f"Error getting seasonal guidance: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/events", response_model=List[Event])
async def get_discover_events(
    lat: float = Query(..., description="User latitude"),
    long: float = Query(..., description="User longitude"),
    radius_miles: float = Query(50.0, description="Search radius in miles"),
    user_elements: Optional[List[str]] = Query(None, description="User's dominant elements (e.g. Fire, Water)"),
    filter_type: Optional[str] = Query(None, description="Filter: 'aligned', 'nearby', or 'all'"),
    event_types: Optional[List[str]] = Query(None, description="Filter by event types"),
):
    """
    Get discoverable events near a location, scored by astrological resonance.
    
    Args:
        lat: User latitude from GPS
        long: User longitude from GPS
        radius_miles: Search radius in miles (1-50)
        user_elements: User's dominant elements from Sun/Moon/Rising
        filter_type: How to filter results - 'aligned' (only matching), 'nearby' (by distance), 'all'
        event_types: Filter to specific event types
        
    Returns:
        List of events with alignment scoring and cosmic reasoning
    """
    try:
        # 1. Get events within radius
        events = event_service.get_nearby_events(lat, long, radius_miles)
        
        # 2. Filter by event type if specified
        if event_types:
            events = [e for e in events if e.event_type.value in event_types]
        
        # 3. Score events based on user elements
        if user_elements:
            # Get seasonal element for additional matching
            seasonal = get_seasonal_guidance()
            events = event_service.score_events_for_user(
                events, 
                user_elements,
                seasonal_element=seasonal.element
            )
        
        # 4. Apply filter type
        if filter_type == "aligned" and user_elements:
            events = [e for e in events if e.alignment_tier and e.alignment_tier.value == "aligned"]
        elif filter_type == "nearby":
            events.sort(key=lambda e: e.distance_miles or 999)
        
        return events
        
    except Exception as e:
        print(f"Error fetching discover events: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/events", response_model=Event)
async def create_event(
    request: CreateEventRequest = Body(...),
    creator_id: str = Query("anonymous", description="ID of the event creator"),
):
    """
    Create a new user event.
    
    Args:
        request: Event creation data
        creator_id: ID of the user creating the event
        
    Returns:
        Created event
    """
    try:
        event = event_service.create_event(request, creator_id)
        return event
    except Exception as e:
        print(f"Error creating event: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/event-types")
async def get_event_types():
    """
    Get all available event types with icons and element affinities.
    
    Returns:
        List of event types with metadata
    """
    return event_service.get_event_types()
