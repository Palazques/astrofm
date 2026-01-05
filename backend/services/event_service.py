"""
Event Service for Discover page.
Provides event data with astrological alignment scoring.

S2: Documentation Rule - All functions include clear docstrings.
H4: Astrology Logic Fidelity - Element matching based on astrology_vibe_logic.md.
"""
from datetime import datetime, timedelta
from typing import List, Optional, Dict
from pydantic import BaseModel
from enum import Enum
import random
import math


class EventType(str, Enum):
    """Event categories with element affinities."""
    SOUND_HEALING = "sound_healing"
    MEDITATION = "meditation"
    FITNESS = "fitness"
    SOCIAL = "social"
    WORKSHOP = "workshop"
    NATURE = "nature"
    CREATIVE = "creative"


# Element affinities for each event type
EVENT_TYPE_ELEMENTS: Dict[EventType, List[str]] = {
    EventType.SOUND_HEALING: ["Water"],
    EventType.MEDITATION: ["Water", "Earth"],
    EventType.FITNESS: ["Fire"],
    EventType.SOCIAL: ["Air"],
    EventType.WORKSHOP: ["Earth", "Air"],
    EventType.NATURE: ["Earth"],
    EventType.CREATIVE: ["Fire", "Water"],
}


EVENT_TYPE_ICONS: Dict[EventType, str] = {
    EventType.SOUND_HEALING: "🎵",
    EventType.MEDITATION: "🧘",
    EventType.FITNESS: "💪",
    EventType.SOCIAL: "👥",
    EventType.WORKSHOP: "📚",
    EventType.NATURE: "🌲",
    EventType.CREATIVE: "🎨",
}


class AlignmentTier(str, Enum):
    """Two-tier alignment system."""
    ALIGNED = "aligned"  # Gold badge - matches user elements or seasonal
    EXPLORE = "explore"  # Silver badge - worth exploring


class Event(BaseModel):
    """Event model with astrological alignment fields."""
    id: str
    title: str
    description: str
    location_name: str
    latitude: float
    longitude: float
    date: datetime
    event_type: EventType
    vibe_tags: List[str]  # e.g., ["Fire", "Active", "Morning"]
    price: Optional[float] = None  # None = free
    image_url: Optional[str] = None
    # Alignment fields (populated by scoring)
    alignment_tier: Optional[AlignmentTier] = None
    cosmic_reasoning: Optional[str] = None
    distance_miles: Optional[float] = None
    # Creator info for user-created events
    creator_id: Optional[str] = None
    cosmic_intention: Optional[str] = None


class CreateEventRequest(BaseModel):
    """Request model for creating a new event."""
    title: str
    description: str
    location_name: str
    latitude: float
    longitude: float
    date: datetime
    event_type: EventType
    price: Optional[float] = None
    cosmic_intention: Optional[str] = None


class EventService:
    """Service for managing events with astrological scoring."""
    
    def __init__(self):
        # Generate dates spread over the next 2 weeks
        now = datetime.now()
        
        self.mock_events: List[Event] = [
            # Sound Healing (Water)
            Event(
                id="1",
                title="Full Moon Sound Bath",
                description="Immerse yourself in crystal bowl vibrations to release old energy.",
                location_name="The Sanctuary",
                latitude=34.0522,
                longitude=-118.2437,
                date=now + timedelta(days=1, hours=19),
                event_type=EventType.SOUND_HEALING,
                vibe_tags=["Water", "Healing", "Moon"],
                price=25.0,
                image_url="https://images.unsplash.com/photo-1519834785169-98be25ec3f84?w=500"
            ),
            Event(
                id="2",
                title="Tibetan Bowl Meditation",
                description="Deep relaxation through ancient sound frequencies.",
                location_name="Zen Space Studio",
                latitude=34.0680,
                longitude=-118.3510,
                date=now + timedelta(days=3, hours=18),
                event_type=EventType.SOUND_HEALING,
                vibe_tags=["Water", "Healing", "Neptune"],
                price=20.0,
                image_url="https://images.unsplash.com/photo-1545389336-cf090694435e?w=500"
            ),
            # Meditation (Water/Earth)
            Event(
                id="3",
                title="Sunrise Breathwork",
                description="Start your day with conscious breathing and intention setting.",
                location_name="Malibu Beach",
                latitude=34.0259,
                longitude=-118.7798,
                date=now + timedelta(days=2, hours=6),
                event_type=EventType.MEDITATION,
                vibe_tags=["Water", "Earth", "Sun"],
                price=None,
                image_url="https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500"
            ),
            # Fitness (Fire)
            Event(
                id="4",
                title="Aries Season HIIT",
                description="Burn off that excess Mars energy with high intensity intervals.",
                location_name="Iron Gym West",
                latitude=34.0622,
                longitude=-118.2537,
                date=now + timedelta(days=1, hours=7),
                event_type=EventType.FITNESS,
                vibe_tags=["Fire", "Active", "Mars"],
                price=15.0,
                image_url="https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500"
            ),
            Event(
                id="5",
                title="Power Yoga Flow",
                description="Dynamic vinyasa to ignite your inner fire.",
                location_name="Hot Yoga LA",
                latitude=34.0195,
                longitude=-118.4912,
                date=now + timedelta(days=4, hours=9),
                event_type=EventType.FITNESS,
                vibe_tags=["Fire", "Active", "Sun"],
                price=22.0,
                image_url="https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500"
            ),
            # Social (Air)
            Event(
                id="6",
                title="Astrology & Coffee",
                description="Discuss current transits with like-minded souls.",
                location_name="Cosmic Cafe",
                latitude=34.0400,
                longitude=-118.2300,
                date=now + timedelta(days=2, hours=10),
                event_type=EventType.SOCIAL,
                vibe_tags=["Air", "Social", "Mercury"],
                price=None,
                image_url="https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500"
            ),
            Event(
                id="7",
                title="New Moon Intention Circle",
                description="Set intentions for the lunar cycle with community.",
                location_name="The Gathering Space",
                latitude=34.0736,
                longitude=-118.2596,
                date=now + timedelta(days=5, hours=19),
                event_type=EventType.SOCIAL,
                vibe_tags=["Air", "Water", "Moon"],
                price=10.0,
                image_url="https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=500"
            ),
            # Workshop (Earth/Air)
            Event(
                id="8",
                title="Birth Chart Reading Workshop",
                description="Learn to read your own natal chart with expert guidance.",
                location_name="Astrology Academy",
                latitude=34.0913,
                longitude=-118.3828,
                date=now + timedelta(days=6, hours=14),
                event_type=EventType.WORKSHOP,
                vibe_tags=["Earth", "Air", "Mercury"],
                price=45.0,
                image_url="https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500"
            ),
            Event(
                id="9",
                title="Tarot for Beginners",
                description="Unlock the mysteries of the cards.",
                location_name="Mystic Books",
                latitude=34.0566,
                longitude=-118.2358,
                date=now + timedelta(days=7, hours=11),
                event_type=EventType.WORKSHOP,
                vibe_tags=["Earth", "Water", "Neptune"],
                price=35.0,
                image_url="https://images.unsplash.com/photo-1601091469299-e4f2c9a7e4c3?w=500"
            ),
            # Nature (Earth)
            Event(
                id="10",
                title="Grounding Forest Walk",
                description="Connect with the earth element. Silent walking meditation.",
                location_name="Griffith Park Trailhead",
                latitude=34.1100,
                longitude=-118.2800,
                date=now + timedelta(days=3, hours=8),
                event_type=EventType.NATURE,
                vibe_tags=["Earth", "Grounding", "Saturn"],
                price=None,
                image_url="https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500"
            ),
            Event(
                id="11",
                title="Beach Sunset Gathering",
                description="Watch the sun set with fellow stargazers.",
                location_name="Venice Beach Pier",
                latitude=33.9850,
                longitude=-118.4695,
                date=now + timedelta(days=4, hours=17),
                event_type=EventType.NATURE,
                vibe_tags=["Earth", "Water", "Venus"],
                price=None,
                image_url="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500"
            ),
            # Creative (Fire/Water)
            Event(
                id="12",
                title="Cosmic Art Jam",
                description="Express your celestial visions through paint and collage.",
                location_name="Art House LA",
                latitude=34.0483,
                longitude=-118.2563,
                date=now + timedelta(days=5, hours=14),
                event_type=EventType.CREATIVE,
                vibe_tags=["Fire", "Water", "Neptune"],
                price=30.0,
                image_url="https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=500"
            ),
        ]
        
        # Store for user-created events
        self.user_events: List[Event] = []
        self._next_id = 100

    def _calculate_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate distance in miles between two points using Haversine formula."""
        R = 3959  # Earth's radius in miles
        
        lat1_rad = math.radians(lat1)
        lat2_rad = math.radians(lat2)
        delta_lat = math.radians(lat2 - lat1)
        delta_lon = math.radians(lon2 - lon1)
        
        a = math.sin(delta_lat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lon/2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        
        return R * c

    def get_all_events(self) -> List[Event]:
        """Get all events (mock + user-created)."""
        return self.mock_events + self.user_events

    def get_nearby_events(
        self, 
        lat: float, 
        lng: float, 
        radius_miles: float = 50.0
    ) -> List[Event]:
        """
        Get events within radius of user location.
        
        Args:
            lat: User latitude
            lng: User longitude
            radius_miles: Search radius in miles
            
        Returns:
            List of events with distance_miles populated
        """
        all_events = self.get_all_events()
        nearby = []
        
        for event in all_events:
            distance = self._calculate_distance(lat, lng, event.latitude, event.longitude)
            if distance <= radius_miles:
                event.distance_miles = round(distance, 1)
                nearby.append(event)
        
        # Sort by distance
        nearby.sort(key=lambda e: e.distance_miles or 999)
        return nearby

    def score_events_for_user(
        self, 
        events: List[Event], 
        user_elements: List[str],
        seasonal_element: Optional[str] = None
    ) -> List[Event]:
        """
        Score events based on user's dominant elements and seasonal recommendations.
        
        Args:
            events: List of events to score
            user_elements: User's dominant elements from Sun/Moon/Rising
            seasonal_element: Current zodiac season's element
            
        Returns:
            Events with alignment_tier and cosmic_reasoning populated
        """
        scored_events = []
        
        for event in events:
            # Check element match
            event_elements = set(EVENT_TYPE_ELEMENTS.get(event.event_type, []))
            event_tags = set(tag for tag in event.vibe_tags if tag in ["Fire", "Earth", "Air", "Water"])
            all_event_elements = event_elements | event_tags
            
            user_element_set = set(user_elements)
            
            # Determine alignment
            matches_user = bool(all_event_elements & user_element_set)
            matches_seasonal = seasonal_element and seasonal_element in all_event_elements
            
            if matches_user or matches_seasonal:
                event.alignment_tier = AlignmentTier.ALIGNED
                
                # Generate cosmic reasoning
                if matches_user:
                    matched = list(all_event_elements & user_element_set)[0]
                    event.cosmic_reasoning = f"Your {matched} energy resonates with this experience"
                elif matches_seasonal:
                    event.cosmic_reasoning = f"Aligned with {seasonal_element} season energy"
            else:
                event.alignment_tier = AlignmentTier.EXPLORE
                
                # Suggest what it offers
                if all_event_elements:
                    element = list(all_event_elements)[0]
                    event.cosmic_reasoning = f"Expand into {element} energy for balance"
                else:
                    event.cosmic_reasoning = "A chance to explore new cosmic territories"
            
            scored_events.append(event)
        
        # Sort: Aligned first, then by distance
        scored_events.sort(
            key=lambda e: (
                0 if e.alignment_tier == AlignmentTier.ALIGNED else 1,
                e.distance_miles or 999
            )
        )
        
        return scored_events

    def create_event(self, request: CreateEventRequest, creator_id: str = "anonymous") -> Event:
        """
        Create a new user event.
        
        Args:
            request: Event creation request
            creator_id: ID of the user creating the event
            
        Returns:
            Created event
        """
        event = Event(
            id=str(self._next_id),
            title=request.title,
            description=request.description,
            location_name=request.location_name,
            latitude=request.latitude,
            longitude=request.longitude,
            date=request.date,
            event_type=request.event_type,
            vibe_tags=list(EVENT_TYPE_ELEMENTS.get(request.event_type, [])),
            price=request.price,
            creator_id=creator_id,
            cosmic_intention=request.cosmic_intention,
        )
        
        self._next_id += 1
        self.user_events.append(event)
        
        return event

    def get_event_types(self) -> List[Dict]:
        """Get all event types with their icons and element affinities."""
        return [
            {
                "type": et.value,
                "icon": EVENT_TYPE_ICONS[et],
                "elements": EVENT_TYPE_ELEMENTS[et],
            }
            for et in EventType
        ]
