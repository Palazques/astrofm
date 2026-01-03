"""
AI Service for generating personalized horoscopes and interpretations.
Uses Gemini as primary provider with OpenAI fallback.

Implements Rule C3: Keys loaded via os.getenv(), never hardcoded.
"""
import logging
import os
import json
import hashlib
from datetime import datetime, timezone, timedelta
from typing import Optional
from dataclasses import dataclass

logger = logging.getLogger(__name__)

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

# Persistent cache import
try:
    import diskcache
    DISKCACHE_AVAILABLE = True
except ImportError:
    DISKCACHE_AVAILABLE = False


@dataclass
class CacheEntry:
    """Cache entry with TTL support."""
    data: dict
    expires_at: datetime


class AIService:
    """
    AI service for generating astrological content.
    
    Primary: Google Gemini (gemini-2.5-flash)
    Fallback: OpenAI (gpt-4o-mini)
    """
    
    # Co-Star inspired system prompt with audio engineering terminology
    SYSTEM_PROMPT = """You are an AI astrologer for Astro.FM, blending Co-Star's minimalist, blunt tone with professional audio engineering terminology.

CORE RULES:
- Translate astrological 'Power/Positive' into 'Resonance' (clarity, flow, synchronization, clean signal)
- Translate astrological 'Pressure/Warning' into 'Feedback' (ego loops, over-processing, clipping, too much gain)  
- Translate astrological 'Trouble/Challenge' into 'Dissonance' (static, interference, out-of-tune, weak signal, phase issues)

AUDIO TERMS TO USE:
- gain, frequency, low-pass filter, reverb, bit-crush
- mono/stereo, phase alignment, latency, room tone
- signal clarity, clipping, compression, headroom
- EQ, overtones, carrier wave, noise floor

TONE:
- Sharp, direct, slightly existential
- No flowery 'New Age' language - be blunt like Co-Star
- Use "you" and "your" - make it personal
- Keep it short: 1-2 sentences max per signal

For playlist parameters, include as JSON on a separate line:
{"bpm_min": int, "bpm_max": int, "energy": 0.0-1.0, "valence": 0.0-1.0, "genres": ["genre1", "genre2"], "key_mode": "major/minor"}
"""

    # Life areas with human-friendly meanings
    LIFE_AREAS = {
        "Self": "How you're showing up today",
        "Communication": "Your mental clarity and expression",
        "Love & Sex": "How in sync you are with partners",
        "Work & Career": "Your focus and productivity", 
        "Creativity": "Your creative spark and expression",
        "Social Life": "How you're connecting with others",
        "Spirituality": "Your inner peace and grounding",
    }

    # Cache TTLs
    DAILY_READING_TTL = timedelta(hours=6)
    COMPATIBILITY_TTL = None  # Indefinite cache for compatibility
    
    def __init__(self, cache_dir: str = "./cache/ai_responses"):
        """Initialize AI service with API keys from environment."""
        # Initialize persistent disk cache (100MB limit)
        # Falls back to in-memory cache if diskcache not available
        if DISKCACHE_AVAILABLE:
            try:
                self._cache = diskcache.Cache(
                    cache_dir,
                    size_limit=100 * 1024 * 1024,  # 100MB
                    eviction_policy='least-recently-used'
                )
                print(f"[AIService] Using persistent disk cache at {cache_dir}")
            except Exception as e:
                print(f"[AIService] Disk cache failed ({e}), using in-memory cache")
                self._cache = {}  # Fallback to in-memory
        else:
            self._cache = {}  # In-memory cache
            print("[AIService] Using in-memory cache (diskcache not installed)")
        
        # Load API keys from environment (Rule C3)
        self._gemini_key = os.getenv("GEMINI_API_KEY")
        self._openai_key = os.getenv("OPENAI_API_KEY")
        
        # Configure Gemini if available
        if GEMINI_AVAILABLE and self._gemini_key:
            genai.configure(api_key=self._gemini_key)
            self._gemini_model = genai.GenerativeModel("gemini-2.5-flash")
            print("[AIService] Configured Gemini provider")
        else:
            self._gemini_model = None
            print("[AIService] Gemini NOT configured (missing key or library)")
        
        # Configure OpenAI if available
        if OPENAI_AVAILABLE and self._openai_key:
            self._openai_client = OpenAI(api_key=self._openai_key)
            print("[AIService] Configured OpenAI provider")
        else:
            self._openai_client = None
            print("[AIService] OpenAI NOT configured (missing key or library)")
    
    def _generate_cache_key(self, prefix: str, data: dict) -> str:
        """Generate a cache key from prefix and data."""
        data_str = json.dumps(data, sort_keys=True)
        hash_val = hashlib.md5(data_str.encode()).hexdigest()[:12]
        return f"{prefix}:{hash_val}"
    
    def _get_cached(self, key: str) -> Optional[dict]:
        """Get cached data if not expired. Works with both disk and in-memory cache."""
        try:
            if isinstance(self._cache, dict):
                # In-memory cache (fallback)
                if key not in self._cache:
                    return None
                entry = self._cache[key]
                if entry.expires_at and datetime.now(timezone.utc) > entry.expires_at:
                    del self._cache[key]
                    return None
                return entry.data
            else:
                # Disk cache with diskcache
                entry = self._cache.get(key)
                if entry is None:
                    return None
                # Check expiration
                if entry.get('expires_at'):
                    expires_at = datetime.fromisoformat(entry['expires_at'])
                    if datetime.now(timezone.utc) > expires_at:
                        del self._cache[key]
                        return None
                return entry.get('data')
        except Exception as e:
            print(f"[AIService] Cache get error: {e}")
            return None
    
    def _set_cached(self, key: str, data: dict, ttl: Optional[timedelta] = None):
        """Cache data with optional TTL. Works with both disk and in-memory cache."""
        try:
            expires_at = datetime.now(timezone.utc) + ttl if ttl else None
            
            if isinstance(self._cache, dict):
                # In-memory cache (fallback)
                self._cache[key] = CacheEntry(data=data, expires_at=expires_at)
            else:
                # Disk cache - store as serializable dict
                entry = {
                    'data': data,
                    'expires_at': expires_at.isoformat() if expires_at else None
                }
                # Use diskcache's expire parameter for automatic cleanup
                expire_seconds = ttl.total_seconds() if ttl else None
                self._cache.set(key, entry, expire=expire_seconds)
        except Exception as e:
            print(f"[AIService] Cache set error: {e}")
    
    def _call_gemini(self, prompt: str) -> str:
        """Call Gemini API using direct generation (faster than chat mode)."""
        if not self._gemini_model:
            raise RuntimeError("Gemini not configured")
        
        print(f"[AIService] Calling Gemini...")
        try:
            # Use direct generate_content instead of chat mode for faster responses
            response = self._gemini_model.generate_content(
                f"{self.SYSTEM_PROMPT}\n\n{prompt}",
                generation_config=genai.GenerationConfig(
                    max_output_tokens=800,
                    temperature=0.7,
                )
            )
            print(f"[AIService] Gemini response received")
            return response.text
        except Exception as e:
            print(f"[AIService] Gemini error: {e}")
            raise
    
    def _call_openai(self, prompt: str) -> str:
        """Call OpenAI API as fallback."""
        if not self._openai_client:
            raise RuntimeError("OpenAI not configured")
        
        print(f"[AIService] Calling OpenAI...")
        try:
            response = self._openai_client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[
                    {"role": "system", "content": self.SYSTEM_PROMPT},
                    {"role": "user", "content": prompt},
                ],
                max_tokens=1000,
            )
            print(f"[AIService] OpenAI response received")
            return response.choices[0].message.content
        except Exception as e:
            print(f"[AIService] OpenAI error: {e}")
            raise
    
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
            except json.JSONDecodeError as e:
                logger.debug(f"Failed to parse playlist params JSON: {e}")
        
        return prose, default_params
    
    def generate_daily_reading(
        self,
        birth_chart: dict,
        current_transits: dict,
        subject_name: str = None,
    ) -> dict:
        """
        Generate a transit-focused daily horoscope.
        
        Uses real astronomical data to create a unique horoscope based on
        today's cosmic weather, personalized by the user's Sun sign.
        
        Args:
            birth_chart: User's natal chart data (mainly uses Sun sign)
            current_transits: Detailed transit data from get_detailed_transit_summary()
            subject_name: Optional name for third-person horoscope
            
        Returns:
            DailyReadingResponse-compatible dict with horoscope fields
        """
        # Extract user's Sun sign (main personalization factor)
        sun_planet = next((p for p in birth_chart.get("planets", []) if p["name"] == "Sun"), {})
        sun_sign = sun_planet.get('sign', 'Unknown')
        
        # Cache by Sun sign + date (same horoscope for all Leos on the same day)
        cache_key = self._generate_cache_key("daily_horoscope_v3", {
            "sun_sign": sun_sign,
            "date": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        })
        
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        # Extract transit data
        moon_sign = current_transits.get('moon_sign', 'Unknown')
        moon_phase = current_transits.get('moon_phase', 'Unknown')
        moon_phase_percent = current_transits.get('moon_phase_percent', 50)
        retrograde_planets = current_transits.get('retrograde_planets', [])
        major_aspects = current_transits.get('major_aspects', [])
        dominant_element = current_transits.get('dominant_element', 'Unknown')
        day_energy = current_transits.get('day_energy', 'Flowing')
        cosmic_weather_raw = current_transits.get('cosmic_weather', '')
        current_season = current_transits.get('sun_sign', 'Unknown')
        
        # Build aspects string for prompt
        if major_aspects:
            aspects_text = "\n".join([f"- {a['planets']} {a['aspect']} (orb: {a['orb']}°)" for a in major_aspects[:4]])
        else:
            aspects_text = "- No major aspects today"
        
        # Build retrograde text
        if retrograde_planets:
            retro_text = ", ".join(retrograde_planets) + " retrograde"
        else:
            retro_text = "No planets retrograde"
        
        # Life areas based on dominant aspects
        focus_areas = ["Self-Expression", "Relationships", "Career", "Inner World", 
                       "Communication", "Finances", "Adventure", "Home Life"]
        
        # Seed focus area selection by date for variety
        import random
        random.seed(datetime.now(timezone.utc).strftime("%Y-%m-%d"))
        default_focus = random.choice(focus_areas)
        
        # Build the horoscope prompt
        prompt = f"""Generate a daily horoscope for {sun_sign} based on TODAY'S cosmic weather.

TODAY'S SKY ({datetime.now(timezone.utc).strftime("%B %d, %Y")}):
- Sun in {current_season} ({current_season} Season)
- Moon: {moon_phase} in {moon_sign} ({moon_phase_percent}% illuminated)
- Dominant Element: {dominant_element}
- {retro_text}

KEY PLANETARY ASPECTS TODAY:
{aspects_text}

OVERALL ENERGY: {day_energy}

Write a horoscope for {sun_sign} that:
1. Reflects TODAY'S specific transits (mention the Moon sign or an aspect)
2. Speaks to how {sun_sign} types will experience this energy
3. Gives one specific, actionable piece of advice
4. Sounds blunt and direct (like Co-Star or The Pattern)
5. Uses "you" and "your"

FORMAT (each on its own line):
HEADLINE: [3-5 word punchy title that captures the day's vibe]
HOROSCOPE: [2-3 sentences. Be specific about today. No vague mysticism.]
FOCUS_AREA: [One area: Self-Expression, Relationships, Career, Inner World, Communication, Finances, Adventure, or Home Life]
ENERGY_LEVEL: [1-100 based on how active/intense the day feels for {sun_sign}]
PLAYLIST_JSON: {{"bpm_min": int, "bpm_max": int, "energy": 0.0-1.0, "valence": 0.0-1.0, "genres": ["genre1", "genre2"], "key_mode": "major/minor"}}

RULES:
- The HEADLINE should be memorable and specific to today
- Reference at least ONE real aspect or the Moon sign in the horoscope
- Energy level should reflect the interplay between {sun_sign}'s nature and today's transits
- Be direct. No "may" or "might" - speak with certainty."""

        response = self._generate_response(prompt)
        
        # Parse the response
        headline = ""
        horoscope = ""
        focus_area = default_focus
        energy_level = 65
        playlist_params = {
            "bpm_min": 100, "bpm_max": 130, "energy": 0.6, 
            "valence": 0.5, "genres": ["electronic", "indie"], "key_mode": "minor"
        }
        
        lines = response.strip().split("\n")
        for line in lines:
            line = line.strip()
            if line.startswith("HEADLINE:"):
                headline = line.replace("HEADLINE:", "").strip()
            elif line.startswith("HOROSCOPE:"):
                horoscope = line.replace("HOROSCOPE:", "").strip()
            elif line.startswith("FOCUS_AREA:"):
                focus_area = line.replace("FOCUS_AREA:", "").strip()
            elif line.startswith("ENERGY_LEVEL:"):
                try:
                    energy_level = int(line.replace("ENERGY_LEVEL:", "").strip())
                    energy_level = max(0, min(100, energy_level))
                except ValueError:
                    pass
            elif line.startswith("PLAYLIST_JSON:"):
                try:
                    import json
                    json_str = line.replace("PLAYLIST_JSON:", "").strip()
                    playlist_params = json.loads(json_str)
                except (json.JSONDecodeError, ValueError):
                    pass
        
        # Fallbacks if parsing failed
        if not headline:
            headline = f"{day_energy} {moon_phase}"
        if not horoscope:
            horoscope = f"The {moon_phase} Moon in {moon_sign} brings {day_energy.lower()} energy today. As a {sun_sign}, lean into this rhythm rather than fighting it. Trust what feels right."
        
        # Build clean cosmic weather string
        cosmic_weather = f"{moon_phase} Moon in {moon_sign}. {retro_text}."
        if major_aspects:
            cosmic_weather += f" {major_aspects[0]['planets']} {major_aspects[0]['aspect']}."
        
        result = {
            "headline": headline,
            "horoscope": horoscope,
            "cosmic_weather": cosmic_weather,
            "energy_level": energy_level,
            "focus_area": focus_area,
            "moon_phase": moon_phase,
            "dominant_element": dominant_element,
            "playlist_params": playlist_params,
            "generated_at": datetime.now(timezone.utc).isoformat(),
            # Legacy fields for backward compatibility
            "reading": horoscope,
            "signals": [],
        }
        
        # Cache result (24 hours)
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
        friend_name: str = None,
    ) -> dict:
        """
        Generate compatibility narrative between two people.
        
        Args:
            user_chart: User's natal chart
            friend_chart: Friend's natal chart
            friend_name: Optional friend's first name for personalized narrative
            
        Returns:
            CompatibilityResponse-compatible dict
        """
        # Check cache (indefinite for compatibility)
        cache_key = self._generate_cache_key("compat", {
            "user_asc": user_chart.get("ascendant_sign", ""),
            "friend_asc": friend_chart.get("ascendant_sign", ""),
            "friend_name": friend_name or "",
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
        
        # Use friend's name or "your friend" as fallback
        friend_label = friend_name if friend_name else "your friend"
        
        prompt = f"""Analyze the sonic compatibility between you and {friend_label}:

You:
- Sun: {user_sun.get('sign', 'Unknown')} (identity tone: 126.22 Hz)
- Moon: {user_moon.get('sign', 'Unknown')} (emotional rhythm)
- Venus: {user_venus.get('sign', 'Unknown')} (harmony style)

{friend_label}:
- Sun: {friend_sun.get('sign', 'Unknown')}
- Moon: {friend_moon.get('sign', 'Unknown')}
- Venus: {friend_venus.get('sign', 'Unknown')}

IMPORTANT: Write the narrative using "you" for the user and "{friend_label}" for the friend. Do NOT use "Person A" or "Person B".

Provide:
1. A 2-3 sentence narrative about your sonic compatibility with {friend_label} (what music you'd make together)
2. 2-3 strengths of this connection
3. 1-2 challenges or growth areas
4. 2-3 shared music genres that would resonate with both of you

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

    def generate_transit_interpretation(
        self,
        transits: list[dict],
        moon_phase: str,
        retrograde_planets: list[str],
    ) -> dict:
        """
        Generate AI interpretation of current planetary transits.
        
        Args:
            transits: List of planet positions [{name, sign, degree, retrograde}, ...]
            moon_phase: Current moon phase name
            retrograde_planets: List of planets currently retrograde
            
        Returns:
            TransitInterpretationResponse-compatible dict
        """
        # Cache key based on date (transits change slowly)
        cache_key = self._generate_cache_key("transit", {
            "date": datetime.now(timezone.utc).strftime("%Y-%m-%d-%H"),  # Hour granularity
        })
        
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        # Build transit summary for prompt
        transit_lines = []
        for t in transits[:8]:  # Main planets
            rx = " (Retrograde)" if t.get("retrograde") else ""
            transit_lines.append(f"- {t['name']}: {t['sign']} {t.get('degree', 0):.1f}°{rx}")
        
        retrograde_text = ", ".join(retrograde_planets) if retrograde_planets else "None"
        
        prompt = f"""Analyze today's cosmic weather based on these planetary transits:

{chr(10).join(transit_lines)}

Moon Phase: {moon_phase}
Retrograde Planets: {retrograde_text}

Provide:
1. A 2-3 sentence "cosmic weather" summary describing today's overall energy in sonic/frequency terms
2. The most significant planet/transit to highlight and why (1 sentence)
3. An energy description keyword (e.g., "Grounding", "Expansive", "Introspective", "Dynamic")

{"IMPORTANT: " + ", ".join(retrograde_planets) + " in retrograde - emphasize how this affects communication, travel, or introspection." if retrograde_planets else ""}

Format your response:
SUMMARY: [cosmic weather summary]
HIGHLIGHT: [planet name] - [why it's significant]
ENERGY: [one-word energy description]"""

        response = self._generate_response(prompt)
        
        # Parse response
        summary = ""
        highlight_planet = ""
        highlight_reason = ""
        energy = "Flowing"
        
        for line in response.strip().split("\n"):
            line = line.strip()
            if line.startswith("SUMMARY:"):
                summary = line.replace("SUMMARY:", "").strip()
            elif line.startswith("HIGHLIGHT:"):
                highlight_text = line.replace("HIGHLIGHT:", "").strip()
                if " - " in highlight_text:
                    parts = highlight_text.split(" - ", 1)
                    highlight_planet = parts[0].strip()
                    highlight_reason = parts[1].strip() if len(parts) > 1 else ""
                else:
                    highlight_planet = highlight_text
            elif line.startswith("ENERGY:"):
                energy = line.replace("ENERGY:", "").strip()
        
        # Fallback if parsing failed
        if not summary:
            summary = f"Today's {moon_phase} brings {energy.lower()} cosmic vibrations."
        if not highlight_planet:
            highlight_planet = "Moon"
            highlight_reason = f"The {moon_phase} sets the emotional tone for today."
        
        result = {
            "interpretation": summary,
            "highlight_planet": highlight_planet,
            "highlight_reason": highlight_reason,
            "energy_description": energy,
            "moon_phase": moon_phase,
            "retrograde_planets": retrograde_planets,
        }
        
        # Cache for 3 hours
        self._set_cached(cache_key, result, timedelta(hours=3))
        
        return result

    def generate_playlist_insight(
        self,
        sun_sign: str,
        moon_sign: str,
        ascendant_sign: str,
        energy_percent: int,
        dominant_mood: str,
        dominant_element: str,
        bpm_range: tuple[int, int],
    ) -> dict:
        """
        Generate a simple, relatable explanation for why this playlist was created.
        
        Args:
            sun_sign: User's sun sign
            moon_sign: User's moon sign (or today's moon sign)
            ascendant_sign: User's rising sign
            energy_percent: Playlist energy level (0-100)
            dominant_mood: Most common mood in playlist
            dominant_element: Most common element (Fire/Earth/Air/Water)
            bpm_range: Min and max BPM in playlist
            
        Returns:
            PlaylistInsightResponse-compatible dict
        """
        prompt = f"""Generate a 1-2 sentence explanation for why this playlist was created for the user. Keep it simple, warm, and relatable - like a friend explaining your vibe.

User's Chart:
- Sun: {sun_sign}
- Moon: {moon_sign}  
- Rising: {ascendant_sign}

Playlist Vibe:
- Energy: {energy_percent}%
- Mood: {dominant_mood}
- Element: {dominant_element}
- BPM Range: {bpm_range[0]}-{bpm_range[1]}

Rules:
1. Keep it SHORT (1-2 sentences max)
2. Make it feel personal and relatable
3. Blend astrological insight with musical description naturally
4. Don't be overly mystical - be conversational
5. Mention the mood or energy naturally

Example style: "With your Scorpio intensity meeting today's dreamy Pisces Moon, we're serving deep, emotional tracks that match your introspective vibe."

Respond ONLY with the insight text, nothing else."""

        response = self._generate_response(prompt)
        insight = response.strip().strip('"')
        
        # Determine astro highlight (most relevant placement)
        astro_highlight = f"{sun_sign} Sun"
        
        return {
            "insight": insight,
            "energy_percent": energy_percent,
            "dominant_mood": dominant_mood,
            "astro_highlight": astro_highlight,
        }

    def generate_sound_interpretation(
        self,
        sun_sign: str,
        moon_sign: str,
        ascendant_sign: str,
        dominant_element: str,
        planets: list[dict],
    ) -> dict:
        """
        Generate AI interpretation of user's cosmic sound profile.
        
        Args:
            sun_sign: User's sun sign
            moon_sign: User's moon sign
            ascendant_sign: User's rising sign
            dominant_element: Dominant element (Fire/Earth/Air/Water)
            planets: List of planet data [{name, sign, house, frequency}, ...]
            
        Returns:
            SoundInterpretationResponse-compatible dict
        """
        # Build planet list for prompt
        planet_lines = []
        for p in planets[:5]:  # Top 5 planets
            planet_lines.append(f"- {p['name']} in {p['sign']} (House {p['house']}, {p['frequency']:.0f} Hz)")
        
        prompt = f"""Generate a personalized sound interpretation for this user. Keep it simple, warm, and relatable - like explaining someone's unique musical vibe.

User's Chart:
- Sun: {sun_sign}
- Moon: {moon_sign}
- Rising: {ascendant_sign}
- Dominant Element: {dominant_element}

Key Planets:
{chr(10).join(planet_lines)}

Provide:
1. PERSONALITY: A 2-sentence description of their overall "sonic personality" - how their chart translates to sound (e.g., "Your sound is warm and grounding with deep undertones...")
2. TODAY: A 1-sentence transit effect on their sound today (make something up that sounds insightful)
3. SHIFT: A short label for today's shift (e.g., "+8% warmth" or "deeper bass")
4. For each planet listed, a SHORT (5-8 words max) musical description

Rules:
- Be conversational and warm, not mystical
- Blend astrology with musical/sonic language naturally
- Keep planet descriptions punchy and memorable

Format:
PERSONALITY: [2 sentences]
TODAY: [1 sentence]
SHIFT: [short label]
SUN: [short description]
MOON: [short description]
MERCURY: [short description]
VENUS: [short description]
MARS: [short description]"""

        response = self._generate_response(prompt)
        
        # Parse response
        personality = ""
        today_influence = ""
        shift = "+5% cosmic"
        planet_descriptions = {}
        
        for line in response.strip().split("\n"):
            line = line.strip()
            if line.startswith("PERSONALITY:"):
                personality = line.replace("PERSONALITY:", "").strip()
            elif line.startswith("TODAY:"):
                today_influence = line.replace("TODAY:", "").strip()
            elif line.startswith("SHIFT:"):
                shift = line.replace("SHIFT:", "").strip()
            elif ":" in line:
                parts = line.split(":", 1)
                planet_name = parts[0].strip().upper()
                if planet_name in ["SUN", "MOON", "MERCURY", "VENUS", "MARS", "JUPITER", "SATURN", "URANUS", "NEPTUNE", "PLUTO"]:
                    planet_descriptions[planet_name.title()] = parts[1].strip()
        
        # Fallbacks
        if not personality:
            personality = f"Your {dominant_element} energy creates a rich, layered sound. The blend of your {sun_sign} Sun and {moon_sign} Moon gives your sound both depth and emotional resonance."
        if not today_influence:
            today_influence = "Today's cosmic weather amplifies your natural frequencies."
        
        return {
            "personality": personality,
            "today_influence": today_influence,
            "shift": shift,
            "planet_descriptions": planet_descriptions,
        }

    def generate_welcome_message(
        self,
        sun_sign: str,
        moon_sign: str,
        ascendant_sign: str,
    ) -> dict:
        """
        Generate a warm, personalized welcome message for new users.
        
        Args:
            sun_sign: User's sun sign
            moon_sign: User's moon sign
            ascendant_sign: User's rising sign
            
        Returns:
            WelcomeMessageResponse-compatible dict
        """
        prompt = f"""Generate a warm, welcoming first-impression message for a new user of Astro.FM, a music app that creates personalized playlists based on astrology.

User's Chart:
- Sun: {sun_sign}
- Moon: {moon_sign}
- Rising: {ascendant_sign}

Provide:
1. GREETING: A personalized 1-sentence warm welcome mentioning their sun sign (e.g., "Welcome, creative {sun_sign}!")
2. PERSONALITY: A friendly 1-2 sentence description of what their chart says about them - blend personality with music/sound naturally
3. SOUND_TEASER: A short, intriguing 1-sentence hint about their unique sound (e.g., "Your sound carries warm, grounding tones with moments of electric intensity")

Rules:
- Be WARM and WELCOMING, like greeting a new friend
- Keep it simple and relatable, not mystical
- Blend astrology with musical/sonic language naturally
- Make them excited to explore their cosmic sound

Format:
GREETING: [1 sentence]
PERSONALITY: [1-2 sentences]
SOUND_TEASER: [1 sentence]"""

        response = self._generate_response(prompt)
        
        # Parse response
        greeting = f"Welcome, {sun_sign}!"
        personality = ""
        sound_teaser = ""
        
        for line in response.strip().split("\n"):
            line = line.strip()
            if line.startswith("GREETING:"):
                greeting = line.replace("GREETING:", "").strip()
            elif line.startswith("PERSONALITY:"):
                personality = line.replace("PERSONALITY:", "").strip()
            elif line.startswith("SOUND_TEASER:"):
                sound_teaser = line.replace("SOUND_TEASER:", "").strip()
        
        # Fallbacks
        if not personality:
            personality = f"Your {sun_sign} Sun brings creative energy, while your {moon_sign} Moon adds emotional depth to everything you do."
        if not sound_teaser:
            sound_teaser = "Your unique sound is ready - tap below to experience your cosmic audio signature."
        
        return {
            "greeting": greeting,
            "personality": personality,
            "sound_teaser": sound_teaser,
        }

    # TTL for monthly horoscope cache (until zodiac period ends)
    MONTHLY_HOROSCOPE_TTL = timedelta(days=30)

    def generate_monthly_horoscope(
        self,
        zodiac_sign: str,
        element: str,
        date_range: str,
        month_year: str,
    ) -> dict:
        """
        Generate monthly zodiac horoscope with music-astrology fusion.
        
        Args:
            zodiac_sign: Current zodiac sign (e.g., "Sagittarius")
            element: Sign's element (e.g., "Fire")
            date_range: Display date range (e.g., "Nov 22 - Dec 21")
            month_year: Current month/year (e.g., "December 2024")
            
        Returns:
            dict with horoscope, vibe_summary, energy_level
        """
        # Cache key based on zodiac sign and month
        cache_key = self._generate_cache_key("monthly_horoscope", {
            "sign": zodiac_sign,
            "month": month_year,
        })
        
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        # Get element descriptions for context
        from services.zodiac_utils import get_element_description
        element_desc = get_element_description(element)
        
        prompt = f"""Generate a monthly horoscope for {zodiac_sign} Season ({date_range}) in {month_year}.

This is for Astro.FM, a music app that blends astrology with sound. The horoscope should:
1. Be relatable and actionable (not vague mysticism)
2. Naturally blend in musical/sound references
3. Give advice on how to approach the month
4. Feel like wisdom from a knowledgeable friend

Context:
- {zodiac_sign} is a {element} sign
- {element} element mood: {element_desc['mood']}
- {element} element sound: {element_desc['sound']}
- Advice tone: {element_desc['advice_tone']}

Provide:
1. HOROSCOPE: A short paragraph (~80-100 words) about the month ahead. Include:
   - What energy this zodiac season brings
   - How to align with it
   - Actionable advice for the month
   - One subtle musical/sonic metaphor

2. VIBE_SUMMARY: A punchy 1-sentence description of the sonic vibe (e.g., "Expect bold anthems and driving beats that match your fearless spirit")

3. ENERGY_LEVEL: A number 1-100 representing the overall energy intensity

IMPORTANT RULES:
- Do NOT mention AI or that this was generated
- Write in second person ("you")
- Be warm, direct, and motivating
- Sound natural, not mystical or esoteric

Format:
HOROSCOPE: [paragraph]
VIBE_SUMMARY: [1 sentence]
ENERGY_LEVEL: [number]"""

        response = self._generate_response(prompt)
        
        # Parse response
        horoscope = ""
        vibe_summary = ""
        energy_level = 70  # Default moderate-high
        
        current_section = None
        horoscope_lines = []
        
        for line in response.strip().split("\n"):
            line = line.strip()
            if line.startswith("HOROSCOPE:"):
                current_section = "horoscope"
                horoscope_lines.append(line.replace("HOROSCOPE:", "").strip())
            elif line.startswith("VIBE_SUMMARY:"):
                current_section = "vibe"
                vibe_summary = line.replace("VIBE_SUMMARY:", "").strip()
            elif line.startswith("ENERGY_LEVEL:"):
                current_section = "energy"
                try:
                    energy_level = int(line.replace("ENERGY_LEVEL:", "").strip())
                    energy_level = max(1, min(100, energy_level))
                except ValueError as e:
                    logger.debug(f"Failed to parse energy level: {e}")
            elif current_section == "horoscope" and line:
                horoscope_lines.append(line)
        
        horoscope = " ".join(horoscope_lines)
        
        # Fallbacks
        if not horoscope:
            horoscope = f"Welcome to {zodiac_sign} season! This month invites you to embrace your inner {element.lower()} energy. {element_desc['advice_tone'].capitalize()}. Let the cosmic rhythms guide your playlist choices as you navigate the weeks ahead with intention and purpose."
        if not vibe_summary:
            vibe_summary = f"Your soundtrack is all about {element_desc['sound']}."
        
        result = {
            "horoscope": horoscope,
            "vibe_summary": vibe_summary,
            "energy_level": energy_level,
        }
        
        # Cache until zodiac period ends (approximately 30 days)
        self._set_cached(cache_key, result, self.MONTHLY_HOROSCOPE_TTL)
        
        return result

    def generate_prescription_text(
        self,
        transit_planet: str,
        natal_planet: str,
        aspect: str,
        recommended_mode: str,
        brainwave_hz: float,
        effect_description: str,
        is_quiet_day: bool = False,
    ) -> dict:
        """
        Generate the 3-part prescription text for cosmic prescription feature.
        
        The prescription has three parts:
        1. What's happening (the transit, in plain language)
        2. How it might feel (the human experience)
        3. What this frequency does about it (the medicine)
        
        Args:
            transit_planet: Name of transiting planet
            natal_planet: Name of natal planet being aspected
            aspect: Aspect type (Square, Trine, Conjunction, etc.)
            recommended_mode: Recommended brainwave mode (focus, calm, etc.)
            brainwave_hz: Frequency in Hz
            effect_description: Short description of what the mode does
            is_quiet_day: True if no significant transits
            
        Returns:
            dict with whats_happening, how_it_feels, what_it_does
        """
        if is_quiet_day:
            return {
                "whats_happening": "The planets are quiet in your chart today. No major transits are demanding your attention.",
                "how_it_feels": "This is a good day to choose your own intention. What do you need right now?",
                "what_it_does": "Select any mode below to set your own cosmic intention for the day.",
            }
        
        # Determine aspect quality for prompt
        aspect_quality = "challenging" if aspect in ["Square", "Opposition"] else "harmonious" if aspect in ["Trine", "Sextile"] else "intense"
        
        prompt = f"""You are a cosmic wellness guide. Generate a 3-part prescription for this transit.

TRANSIT:
- {transit_planet} is forming a {aspect} to their natal {natal_planet}
- This is a {aspect_quality} aspect
- Recommended mode: {recommended_mode.upper()} ({brainwave_hz} Hz)
- Effect: {effect_description}

Generate exactly 3 parts:

1. WHATS_HAPPENING: A 1-2 sentence plain-language explanation of what this transit means. Use "is" not "was". Be specific about the planetary energy. Example: "Mercury is clashing with your Mars today."

2. HOW_IT_FEELS: A 1-2 sentence description of how this might feel in daily life. Be relatable and specific. Example: "Words may come out sharper than intended, and your mind might race ahead of your patience."

3. WHAT_IT_DOES: A 1-2 sentence explanation of what the {brainwave_hz} Hz {recommended_mode} frequency does to help. Use action verbs like "synchronizes", "anchors", "creates space", "metabolizes". Example: "This frequency synchronizes scattered mental energy, helping you think before you speak."

RULES:
- Be warm and conversational, not mystical
- Make it specific to {transit_planet} and {natal_planet}
- Keep each part short (1-2 sentences max)
- Don't use "you will" - use present tense
- Don't mention "binaural" or technical terms

Format:
WHATS_HAPPENING: [text]
HOW_IT_FEELS: [text]
WHAT_IT_DOES: [text]"""

        response = self._generate_response(prompt)
        
        # Parse response
        whats_happening = ""
        how_it_feels = ""
        what_it_does = ""
        
        for line in response.strip().split("\n"):
            line = line.strip()
            if line.startswith("WHATS_HAPPENING:"):
                whats_happening = line.replace("WHATS_HAPPENING:", "").strip()
            elif line.startswith("HOW_IT_FEELS:"):
                how_it_feels = line.replace("HOW_IT_FEELS:", "").strip()
            elif line.startswith("WHAT_IT_DOES:"):
                what_it_does = line.replace("WHAT_IT_DOES:", "").strip()
        
        # Fallbacks if parsing failed
        if not whats_happening:
            whats_happening = f"{transit_planet} is forming a {aspect.lower()} with your natal {natal_planet} today."
        if not how_it_feels:
            how_it_feels = f"You may notice {transit_planet}'s energy influencing your {natal_planet} themes."
        if not what_it_does:
            what_it_does = f"This {brainwave_hz} Hz frequency {effect_description}."
        
        return {
            "whats_happening": whats_happening,
            "how_it_feels": how_it_feels,
            "what_it_does": what_it_does,
        }


# Global singleton instance
_ai_service: Optional[AIService] = None


def get_ai_service() -> AIService:
    """Get or create AI service singleton."""
    global _ai_service
    if _ai_service is None:
        _ai_service = AIService()
    return _ai_service
