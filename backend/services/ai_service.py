"""
AI Service for generating personalized horoscopes and interpretations.
Uses Gemini as primary provider with OpenAI fallback.

Implements Rule C3: Keys loaded via os.getenv(), never hardcoded.
"""
import os
import json
import hashlib
from datetime import datetime, timezone, timedelta
from typing import Optional
from dataclasses import dataclass

# AI Provider imports
try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False

try:
    from openai import OpenAI
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False


@dataclass
class CacheEntry:
    """Cache entry with TTL support."""
    data: dict
    expires_at: datetime


class AIService:
    """
    AI service for generating astrological content.
    
    Primary: Google Gemini (gemini-1.5-flash)
    Fallback: OpenAI (gpt-4o-mini)
    """
    
    # Astro.FM voice system prompt - references astrology_vibe_logic.md
    SYSTEM_PROMPT = """You are the AI voice of Astro.FM, a cosmic audio experience app.

Your tone is:
- Mystical but grounded - speak with cosmic wisdom, not vague mysticism
- Music-literate - naturally reference BPM, genres, frequencies, textures, sonic qualities
- Astrologically precise - reference specific planetary placements and their meanings

Planet-to-Music Mapping (from our sound signature system):
- Sun (126.22 Hz, B): Identity, vitality - foundation/carrier tone
- Moon (210.42 Hz, G#): Emotion, intuition - rhythmic/fluid modulation
- Mercury (141.27 Hz, C#): Communication, clarity - high-frequency detail
- Mars (144.72 Hz, C#): Drive, action - pulsing/percussive
- Jupiter (183.58 Hz, F#): Expansion, optimism - harmonic layers
- Saturn (147.85 Hz, D): Structure, discipline - low-frequency grounding
- Uranus (207.36 Hz, G#): Innovation, disruption - glitch/unpredictable
- Neptune (211.44 Hz, G#): Dreams, spirituality - reverb/echo ambient
- Pluto (140.25 Hz, C#): Transformation, intensity - sub-bass/intense

House Sound Qualities:
- Angular houses (1,4,7,10): Lead, focused, authoritative
- Succedent houses (2,5,8,11): Warm, bright, deep textures
- Cadent houses (3,6,9,12): Fast patterns, rhythmic, ambient

When responding:
1. Always ground your reading in the user's specific planetary placements
2. Translate cosmic energy into sonic metaphors and playlist parameters
3. Keep readings concise but meaningful (2-4 sentences for horoscopes)
4. End with actionable musical guidance

For playlist parameters, always include as JSON on a separate line:
{"bpm_min": int, "bpm_max": int, "energy": 0.0-1.0, "valence": 0.0-1.0, "genres": ["genre1", "genre2"], "key_mode": "major/minor"}
"""

    # Cache TTLs
    DAILY_READING_TTL = timedelta(hours=6)
    COMPATIBILITY_TTL = None  # Indefinite cache for compatibility
    
    def __init__(self):
        """Initialize AI service with API keys from environment."""
        self._cache: dict[str, CacheEntry] = {}
        
        # Load API keys from environment (Rule C3)
        self._gemini_key = os.getenv("GEMINI_API_KEY")
        self._openai_key = os.getenv("OPENAI_API_KEY")
        
        # Configure Gemini if available
        if GEMINI_AVAILABLE and self._gemini_key:
            genai.configure(api_key=self._gemini_key)
            self._gemini_model = genai.GenerativeModel("gemini-1.5-flash")
        else:
            self._gemini_model = None
        
        # Configure OpenAI if available
        if OPENAI_AVAILABLE and self._openai_key:
            self._openai_client = OpenAI(api_key=self._openai_key)
        else:
            self._openai_client = None
    
    def _generate_cache_key(self, prefix: str, data: dict) -> str:
        """Generate a cache key from prefix and data."""
        data_str = json.dumps(data, sort_keys=True)
        hash_val = hashlib.md5(data_str.encode()).hexdigest()[:12]
        return f"{prefix}:{hash_val}"
    
    def _get_cached(self, key: str) -> Optional[dict]:
        """Get cached data if not expired."""
        if key not in self._cache:
            return None
        
        entry = self._cache[key]
        if entry.expires_at and datetime.now(timezone.utc) > entry.expires_at:
            del self._cache[key]
            return None
        
        return entry.data
    
    def _set_cached(self, key: str, data: dict, ttl: Optional[timedelta] = None):
        """Cache data with optional TTL."""
        expires_at = datetime.now(timezone.utc) + ttl if ttl else None
        self._cache[key] = CacheEntry(data=data, expires_at=expires_at)
    
    def _call_gemini(self, prompt: str) -> str:
        """Call Gemini API."""
        if not self._gemini_model:
            raise RuntimeError("Gemini not configured")
        
        chat = self._gemini_model.start_chat(history=[])
        response = chat.send_message(f"{self.SYSTEM_PROMPT}\n\n{prompt}")
        return response.text
    
    def _call_openai(self, prompt: str) -> str:
        """Call OpenAI API as fallback."""
        if not self._openai_client:
            raise RuntimeError("OpenAI not configured")
        
        response = self._openai_client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": self.SYSTEM_PROMPT},
                {"role": "user", "content": prompt},
            ],
            max_tokens=1000,
        )
        return response.choices[0].message.content
    
    def _generate_response(self, prompt: str) -> str:
        """Generate AI response with fallback."""
        # Try Gemini first
        if self._gemini_model:
            try:
                return self._call_gemini(prompt)
            except Exception as e:
                print(f"[AIService] Gemini failed: {e}, falling back to OpenAI")
        
        # Fallback to OpenAI
        if self._openai_client:
            try:
                return self._call_openai(prompt)
            except Exception as e:
                print(f"[AIService] OpenAI failed: {e}")
                raise RuntimeError("All AI providers failed")
        
        raise RuntimeError("No AI providers configured")
    
    def _parse_response(self, response: str) -> tuple[str, dict]:
        """
        Parse AI response into prose and JSON parameters.
        
        Expected format:
        Prose text here...
        {"bpm_min": 120, "bpm_max": 128, ...}
        
        Returns:
            Tuple of (prose_text, parsed_json_or_defaults)
        """
        lines = response.strip().split("\n")
        
        # Find JSON line (last line that starts with {)
        json_line = None
        prose_lines = []
        
        for line in lines:
            stripped = line.strip()
            if stripped.startswith("{") and stripped.endswith("}"):
                json_line = stripped
            else:
                prose_lines.append(line)
        
        prose = "\n".join(prose_lines).strip()
        
        # Parse JSON or use defaults
        default_params = {
            "bpm_min": 110,
            "bpm_max": 130,
            "energy": 0.6,
            "valence": 0.5,
            "genres": ["electronic", "ambient"],
            "key_mode": "minor",
        }
        
        if json_line:
            try:
                params = json.loads(json_line)
                # Merge with defaults for any missing keys
                for key, value in default_params.items():
                    if key not in params:
                        params[key] = value
                return prose, params
            except json.JSONDecodeError:
                pass
        
        return prose, default_params
    
    def generate_daily_reading(
        self,
        birth_chart: dict,
        current_transits: dict,
    ) -> dict:
        """
        Generate personalized daily reading with playlist parameters.
        
        Args:
            birth_chart: User's natal chart data
            current_transits: Current planetary positions
            
        Returns:
            DailyReadingResponse-compatible dict
        """
        # Check cache
        cache_key = self._generate_cache_key("daily", {
            "chart": birth_chart.get("ascendant_sign", ""),
            "date": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        })
        
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        # Build prompt
        sun_planet = next((p for p in birth_chart.get("planets", []) if p["name"] == "Sun"), {})
        moon_planet = next((p for p in birth_chart.get("planets", []) if p["name"] == "Moon"), {})
        
        prompt = f"""Generate a daily sonic horoscope for this user:

Birth Chart Summary:
- Sun: {sun_planet.get('sign', 'Unknown')} in House {sun_planet.get('house', '?')}
- Moon: {moon_planet.get('sign', 'Unknown')} in House {moon_planet.get('house', '?')}
- Ascendant: {birth_chart.get('ascendant_sign', 'Unknown')} Rising

Today's Transits:
- Current Moon: {current_transits.get('moon_sign', 'Unknown')}
- Season: {current_transits.get('season', 'Unknown')}
- Retrograde Planets: {', '.join(current_transits.get('retrograde_planets', [])) or 'None'}

Provide:
1. A 2-3 sentence personalized reading connecting their chart to today's energy
2. Sonic/musical guidance for the day
3. JSON playlist parameters on a separate line"""

        response = self._generate_response(prompt)
        reading, params = self._parse_response(response)
        
        # Determine cosmic weather from transits
        retrograde_count = len(current_transits.get('retrograde_planets', []))
        if retrograde_count >= 3:
            cosmic_weather = "Mercury Retrograde vibes - reflective and introspective"
        elif retrograde_count > 0:
            cosmic_weather = f"{current_transits.get('moon_sign', 'Unknown')} Moon - {', '.join(current_transits.get('retrograde_planets', []))} in retrograde"
        else:
            cosmic_weather = f"{current_transits.get('moon_sign', 'Unknown')} Moon - flowing cosmic energy"
        
        result = {
            "reading": reading,
            "playlist_params": params,
            "cosmic_weather": cosmic_weather,
            "generated_at": datetime.now(timezone.utc).isoformat(),
        }
        
        # Cache result
        self._set_cached(cache_key, result, self.DAILY_READING_TTL)
        
        return result
    
    def generate_alignment_interpretation(
        self,
        chart_a: dict,
        chart_b: dict,
        resonance_score: int,
    ) -> dict:
        """
        Generate interpretation for alignment between two charts.
        
        Args:
            chart_a: First chart (usually user)
            chart_b: Second chart (today's transits or friend)
            resonance_score: Calculated resonance score (0-100)
            
        Returns:
            AlignmentInterpretation-compatible dict
        """
        sun_a = next((p for p in chart_a.get("planets", []) if p["name"] == "Sun"), {})
        moon_a = next((p for p in chart_a.get("planets", []) if p["name"] == "Moon"), {})
        
        prompt = f"""Interpret this cosmic alignment:

Chart A (User):
- Sun: {sun_a.get('sign', 'Unknown')}
- Moon: {moon_a.get('sign', 'Unknown')}
- Ascendant: {chart_a.get('ascendant_sign', 'Unknown')}

Chart B (Target - could be today's sky or another person):
- Dominant energy: {chart_b.get('ascendant_sign', chart_b.get('moon_sign', 'Unknown'))}

Resonance Score: {resonance_score}%

Provide a 2-3 sentence interpretation of this alignment in sonic/frequency terms.
What frequencies are harmonizing? What's the "sound" of this connection?
Do NOT include JSON parameters for this response."""

        response = self._generate_response(prompt)
        interpretation = response.strip()
        
        # Determine if harmonious based on score
        harmonious = resonance_score >= 70
        
        # Generate aspect descriptions
        harmonious_aspects = []
        if resonance_score >= 85:
            harmonious_aspects = ["Trine formation", "Harmonic resonance", "Complementary frequencies"]
        elif resonance_score >= 70:
            harmonious_aspects = ["Sextile aspects", "Supportive undertones"]
        elif resonance_score >= 50:
            harmonious_aspects = ["Square tension creating dynamic energy"]
        else:
            harmonious_aspects = ["Oppositional frequencies seeking balance"]
        
        return {
            "interpretation": interpretation,
            "resonance_score": resonance_score,
            "harmonious_aspects": harmonious_aspects,
        }
    
    def generate_compatibility_narrative(
        self,
        user_chart: dict,
        friend_chart: dict,
    ) -> dict:
        """
        Generate compatibility narrative between two people.
        
        Args:
            user_chart: User's natal chart
            friend_chart: Friend's natal chart
            
        Returns:
            CompatibilityResponse-compatible dict
        """
        # Check cache (indefinite for compatibility)
        cache_key = self._generate_cache_key("compat", {
            "user_asc": user_chart.get("ascendant_sign", ""),
            "friend_asc": friend_chart.get("ascendant_sign", ""),
        })
        
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        user_sun = next((p for p in user_chart.get("planets", []) if p["name"] == "Sun"), {})
        user_moon = next((p for p in user_chart.get("planets", []) if p["name"] == "Moon"), {})
        user_venus = next((p for p in user_chart.get("planets", []) if p["name"] == "Venus"), {})
        
        friend_sun = next((p for p in friend_chart.get("planets", []) if p["name"] == "Sun"), {})
        friend_moon = next((p for p in friend_chart.get("planets", []) if p["name"] == "Moon"), {})
        friend_venus = next((p for p in friend_chart.get("planets", []) if p["name"] == "Venus"), {})
        
        prompt = f"""Analyze the sonic compatibility between these two people:

Person A:
- Sun: {user_sun.get('sign', 'Unknown')} (identity tone: 126.22 Hz)
- Moon: {user_moon.get('sign', 'Unknown')} (emotional rhythm)
- Venus: {user_venus.get('sign', 'Unknown')} (harmony style)

Person B:
- Sun: {friend_sun.get('sign', 'Unknown')}
- Moon: {friend_moon.get('sign', 'Unknown')}
- Venus: {friend_venus.get('sign', 'Unknown')}

Provide:
1. A 2-3 sentence narrative about their sonic compatibility (what music they'd make together)
2. 2-3 strengths of this connection
3. 1-2 challenges or growth areas
4. 2-3 shared music genres that would resonate with both

Format your response with clear sections:
NARRATIVE: [your narrative]
STRENGTHS: [comma-separated list]
CHALLENGES: [comma-separated list]  
GENRES: [comma-separated list]"""

        response = self._generate_response(prompt)
        
        # Parse structured response
        narrative = ""
        strengths = []
        challenges = []
        genres = []
        
        current_section = None
        for line in response.strip().split("\n"):
            line = line.strip()
            if line.startswith("NARRATIVE:"):
                current_section = "narrative"
                narrative = line.replace("NARRATIVE:", "").strip()
            elif line.startswith("STRENGTHS:"):
                current_section = "strengths"
                strengths = [s.strip() for s in line.replace("STRENGTHS:", "").split(",")]
            elif line.startswith("CHALLENGES:"):
                current_section = "challenges"
                challenges = [c.strip() for c in line.replace("CHALLENGES:", "").split(",")]
            elif line.startswith("GENRES:"):
                current_section = "genres"
                genres = [g.strip() for g in line.replace("GENRES:", "").split(",")]
            elif current_section == "narrative" and line:
                narrative += " " + line
        
        # Calculate overall score based on element compatibility
        # (simplified - would use proper aspect calculation in production)
        score = 75  # Default moderate compatibility
        
        # Use defaults if parsing failed
        if not narrative:
            narrative = "These two frequencies create an interesting harmonic when combined."
        if not strengths:
            strengths = ["Complementary energies", "Shared curiosity"]
        if not challenges:
            challenges = ["Different communication rhythms"]
        if not genres:
            genres = ["Electronic", "Ambient", "Indie"]
        
        result = {
            "narrative": narrative,
            "overall_score": score,
            "strengths": strengths[:3],
            "challenges": challenges[:2],
            "shared_genres": genres[:3],
        }
        
        # Cache indefinitely
        self._set_cached(cache_key, result, None)
        
        return result


# Global singleton instance
_ai_service: Optional[AIService] = None


def get_ai_service() -> AIService:
    """Get or create AI service singleton."""
    global _ai_service
    if _ai_service is None:
        _ai_service = AIService()
    return _ai_service
