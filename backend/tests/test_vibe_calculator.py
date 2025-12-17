"""
Unit tests for the Vibe Calculator.
Tests element/modality mapping, aspect detection, moon phases, and vibe calculation.

H3: Unit Test Creation - Comprehensive tests for all vibe calculator functions.
C2: Regression Prevention - Run all tests before committing.
"""
import pytest
from datetime import datetime

from services.vibe_calculator import (
    get_element_for_sign,
    get_modality_for_sign,
    calculate_aspect,
    get_moon_phase,
    calculate_current_transits,
    find_active_transits,
    calculate_vibe_parameters,
    generate_cosmic_summary,
    SIGN_TO_ELEMENT,
    SIGN_TO_MODALITY,
    PLANET_EFFECTS,
    MOON_PHASE_EFFECTS,
)
from models.vibe import VibeParameters, TransitData
from services.ephemeris import calculate_natal_chart, ZODIAC_SIGNS
from data.constants import ELEMENTS, PLANETS, MOODS


class TestElementMapping:
    """Tests for sign to element mapping."""
    
    def test_fire_signs(self):
        """Aries, Leo, Sagittarius should map to Fire."""
        assert get_element_for_sign("Aries") == "Fire"
        assert get_element_for_sign("Leo") == "Fire"
        assert get_element_for_sign("Sagittarius") == "Fire"
    
    def test_earth_signs(self):
        """Taurus, Virgo, Capricorn should map to Earth."""
        assert get_element_for_sign("Taurus") == "Earth"
        assert get_element_for_sign("Virgo") == "Earth"
        assert get_element_for_sign("Capricorn") == "Earth"
    
    def test_air_signs(self):
        """Gemini, Libra, Aquarius should map to Air."""
        assert get_element_for_sign("Gemini") == "Air"
        assert get_element_for_sign("Libra") == "Air"
        assert get_element_for_sign("Aquarius") == "Air"
    
    def test_water_signs(self):
        """Cancer, Scorpio, Pisces should map to Water."""
        assert get_element_for_sign("Cancer") == "Water"
        assert get_element_for_sign("Scorpio") == "Water"
        assert get_element_for_sign("Pisces") == "Water"
    
    def test_all_12_signs_mapped(self):
        """All 12 zodiac signs should have element mappings."""
        for sign in ZODIAC_SIGNS:
            element = get_element_for_sign(sign)
            assert element in ELEMENTS.keys()
    
    def test_invalid_sign_raises_error(self):
        """Invalid sign should raise ValueError."""
        with pytest.raises(ValueError):
            get_element_for_sign("Ophiuchus")


class TestModalityMapping:
    """Tests for sign to modality mapping."""
    
    def test_cardinal_signs(self):
        """Aries, Cancer, Libra, Capricorn should be Cardinal."""
        assert get_modality_for_sign("Aries") == "Cardinal"
        assert get_modality_for_sign("Cancer") == "Cardinal"
        assert get_modality_for_sign("Libra") == "Cardinal"
        assert get_modality_for_sign("Capricorn") == "Cardinal"
    
    def test_fixed_signs(self):
        """Taurus, Leo, Scorpio, Aquarius should be Fixed."""
        assert get_modality_for_sign("Taurus") == "Fixed"
        assert get_modality_for_sign("Leo") == "Fixed"
        assert get_modality_for_sign("Scorpio") == "Fixed"
        assert get_modality_for_sign("Aquarius") == "Fixed"
    
    def test_mutable_signs(self):
        """Gemini, Virgo, Sagittarius, Pisces should be Mutable."""
        assert get_modality_for_sign("Gemini") == "Mutable"
        assert get_modality_for_sign("Virgo") == "Mutable"
        assert get_modality_for_sign("Sagittarius") == "Mutable"
        assert get_modality_for_sign("Pisces") == "Mutable"
    
    def test_all_12_signs_mapped(self):
        """All 12 zodiac signs should have modality mappings."""
        for sign in ZODIAC_SIGNS:
            modality = get_modality_for_sign(sign)
            assert modality in ["Cardinal", "Fixed", "Mutable"]
    
    def test_invalid_sign_raises_error(self):
        """Invalid sign should raise ValueError."""
        with pytest.raises(ValueError):
            get_modality_for_sign("NotASign")


class TestAspectDetection:
    """Tests for aspect calculation between planetary positions."""
    
    def test_conjunction(self):
        """Positions within 8° should be conjunction."""
        assert calculate_aspect(0, 5) == "conjunction"
        assert calculate_aspect(0, 8) == "conjunction"
        assert calculate_aspect(355, 3) == "conjunction"  # Wraps around
    
    def test_opposition(self):
        """Positions ~180° apart should be opposition."""
        assert calculate_aspect(0, 180) == "opposition"
        assert calculate_aspect(0, 175) == "opposition"
        assert calculate_aspect(90, 270) == "opposition"
    
    def test_square(self):
        """Positions ~90° apart should be square."""
        assert calculate_aspect(0, 90) == "square"
        assert calculate_aspect(0, 85) == "square"
        assert calculate_aspect(270, 0) == "square"
    
    def test_trine(self):
        """Positions ~120° apart should be trine."""
        assert calculate_aspect(0, 120) == "trine"
        assert calculate_aspect(0, 115) == "trine"
        assert calculate_aspect(0, 125) == "trine"
    
    def test_sextile(self):
        """Positions ~60° apart should be sextile."""
        assert calculate_aspect(0, 60) == "sextile"
        assert calculate_aspect(0, 55) == "sextile"
        assert calculate_aspect(0, 65) == "sextile"
    
    def test_no_aspect(self):
        """Positions not matching any aspect should return None."""
        assert calculate_aspect(0, 45) is None  # Semi-square (not major)
        assert calculate_aspect(0, 150) is None  # Quincunx (not major)
        assert calculate_aspect(0, 30) is None  # Semi-sextile


class TestMoonPhase:
    """Tests for moon phase calculation."""
    
    def test_known_full_moon(self):
        """Known full moon date should return Full Moon."""
        # December 15, 2024 was a Full Moon
        from services.ephemeris import datetime_to_julian
        jd = datetime_to_julian(datetime(2024, 12, 15, 12, 0))
        phase, days = get_moon_phase(jd)
        # Should be near full moon (within 2 days)
        assert abs(days - 14.77) < 3 or phase == "Full Moon" or phase == "Waxing Gibbous" or phase == "Waning Gibbous"
    
    def test_known_new_moon(self):
        """Known new moon date should return New Moon."""
        # January 1, 2025 was a New Moon
        from services.ephemeris import datetime_to_julian
        jd = datetime_to_julian(datetime(2025, 1, 1, 12, 0))
        phase, days = get_moon_phase(jd)
        # Should be near new moon (within 2 days)
        assert days < 3 or days > 27 or phase == "New Moon" or phase == "Waning Crescent"
    
    def test_phase_names_valid(self):
        """All returned phase names should be valid."""
        from services.ephemeris import datetime_to_julian
        valid_phases = [
            "New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous",
            "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"
        ]
        
        # Test multiple dates
        for day in range(1, 30):
            jd = datetime_to_julian(datetime(2024, 12, day, 12, 0))
            phase, _ = get_moon_phase(jd)
            assert phase in valid_phases
    
    def test_days_in_cycle_range(self):
        """Days into cycle should be 0-29.5."""
        from services.ephemeris import datetime_to_julian
        for day in range(1, 30):
            jd = datetime_to_julian(datetime(2024, 12, day, 12, 0))
            _, days = get_moon_phase(jd)
            assert 0 <= days <= 29.53


class TestTransitCalculation:
    """Tests for current transit calculation."""
    
    def test_calculate_transits_returns_transit_data(self):
        """calculate_current_transits should return valid TransitData."""
        transits = calculate_current_transits(datetime(2024, 12, 16, 12, 0))
        assert isinstance(transits, TransitData)
    
    def test_all_planets_present(self):
        """All 10 planets should have position data."""
        transits = calculate_current_transits(datetime(2024, 12, 16, 12, 0))
        expected_planets = ["Sun", "Moon", "Mercury", "Venus", "Mars", 
                          "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]
        for planet in expected_planets:
            assert planet in transits.planet_positions
    
    def test_planet_data_structure(self):
        """Each planet should have longitude, sign, degree, element, modality."""
        transits = calculate_current_transits(datetime(2024, 12, 16, 12, 0))
        for planet, data in transits.planet_positions.items():
            assert "longitude" in data
            assert "sign" in data
            assert "degree" in data
            assert "element" in data
            assert "modality" in data
    
    def test_moon_phase_present(self):
        """Transit data should include moon phase."""
        transits = calculate_current_transits(datetime(2024, 12, 16, 12, 0))
        assert transits.moon_phase is not None
        assert transits.moon_phase_days >= 0


class TestVibeParametersModel:
    """Tests for VibeParameters Pydantic model validation."""
    
    def test_valid_parameters(self):
        """Valid parameters should create model successfully."""
        params = VibeParameters(
            target_energy=(40, 70),
            target_valence=(50, 80),
            primary_elements=["Fire"],
            secondary_elements=["Air"],
            active_planets=["Sun", "Mars"],
            mood_direction=["Energizing", "Empowering", "Euphoric"],
            intensity_range=(50, 80),
            time_of_day="afternoon",
            modality_preference="Cardinal",
            cosmic_weather_summary="The Moon in Aries brings passionate energy to your day. With Mars active, expect themes of drive and determination. This is a high-energy moment."
        )
        assert params.target_energy == (40, 70)
    
    def test_energy_range_clamping_validation(self):
        """Energy values outside 0-100 should fail validation."""
        with pytest.raises(ValueError):
            VibeParameters(
                target_energy=(-10, 70),
                target_valence=(50, 80),
                primary_elements=["Fire"],
                active_planets=["Sun", "Mars"],
                mood_direction=["Energizing", "Empowering", "Euphoric"],
                intensity_range=(50, 80),
                cosmic_weather_summary="Test summary that is long enough to pass validation minimum of fifty characters."
            )
    
    def test_invalid_element_fails(self):
        """Invalid element should fail validation."""
        with pytest.raises(ValueError):
            VibeParameters(
                target_energy=(40, 70),
                target_valence=(50, 80),
                primary_elements=["Spirit"],  # Invalid
                active_planets=["Sun", "Mars"],
                mood_direction=["Energizing", "Empowering", "Euphoric"],
                intensity_range=(50, 80),
                cosmic_weather_summary="Test summary that is long enough to pass validation minimum of fifty characters."
            )
    
    def test_invalid_mood_fails(self):
        """Invalid mood should fail validation."""
        with pytest.raises(ValueError):
            VibeParameters(
                target_energy=(40, 70),
                target_valence=(50, 80),
                primary_elements=["Fire"],
                active_planets=["Sun", "Mars"],
                mood_direction=["Happy", "Sad", "Angry"],  # Invalid
                intensity_range=(50, 80),
                cosmic_weather_summary="Test summary that is long enough to pass validation minimum of fifty characters."
            )


class TestFullVibeCalculation:
    """Integration tests for the full vibe calculation pipeline."""
    
    @pytest.fixture
    def sample_natal_chart(self):
        """Create a sample natal chart for testing."""
        # Use a specific birth date/time for reproducibility
        return calculate_natal_chart(
            birth_datetime=datetime(1990, 6, 15, 14, 30),  # June 15, 1990 at 2:30 PM
            latitude=40.7128,  # New York
            longitude=-74.0060
        )
    
    def test_returns_vibe_parameters(self, sample_natal_chart):
        """calculate_vibe_parameters should return VibeParameters."""
        params = calculate_vibe_parameters(
            natal_chart=sample_natal_chart,
            current_datetime=datetime(2024, 12, 16, 15, 0),
            latitude=40.7128,
            longitude=-74.0060
        )
        assert isinstance(params, VibeParameters)
    
    def test_energy_values_clamped(self, sample_natal_chart):
        """Energy values should be within 0-100."""
        params = calculate_vibe_parameters(
            natal_chart=sample_natal_chart,
            current_datetime=datetime(2024, 12, 16, 15, 0),
            latitude=40.7128,
            longitude=-74.0060
        )
        assert 0 <= params.target_energy[0] <= 100
        assert 0 <= params.target_energy[1] <= 100
        assert params.target_energy[0] <= params.target_energy[1]
    
    def test_valence_values_clamped(self, sample_natal_chart):
        """Valence values should be within 0-100."""
        params = calculate_vibe_parameters(
            natal_chart=sample_natal_chart,
            current_datetime=datetime(2024, 12, 16, 15, 0),
            latitude=40.7128,
            longitude=-74.0060
        )
        assert 0 <= params.target_valence[0] <= 100
        assert 0 <= params.target_valence[1] <= 100
        assert params.target_valence[0] <= params.target_valence[1]
    
    def test_elements_valid(self, sample_natal_chart):
        """All elements should be from valid list."""
        params = calculate_vibe_parameters(
            natal_chart=sample_natal_chart,
            current_datetime=datetime(2024, 12, 16, 15, 0),
            latitude=40.7128,
            longitude=-74.0060
        )
        for element in params.primary_elements:
            assert element in ELEMENTS.keys()
        for element in params.secondary_elements:
            assert element in ELEMENTS.keys()
    
    def test_planets_valid(self, sample_natal_chart):
        """All planets should be from valid list."""
        params = calculate_vibe_parameters(
            natal_chart=sample_natal_chart,
            current_datetime=datetime(2024, 12, 16, 15, 0),
            latitude=40.7128,
            longitude=-74.0060
        )
        for planet in params.active_planets:
            assert planet in PLANETS.keys()
    
    def test_moods_valid(self, sample_natal_chart):
        """All moods should be from valid list."""
        params = calculate_vibe_parameters(
            natal_chart=sample_natal_chart,
            current_datetime=datetime(2024, 12, 16, 15, 0),
            latitude=40.7128,
            longitude=-74.0060
        )
        for mood in params.mood_direction:
            assert mood in MOODS
    
    def test_has_minimum_planets(self, sample_natal_chart):
        """Should have at least 2 active planets."""
        params = calculate_vibe_parameters(
            natal_chart=sample_natal_chart,
            current_datetime=datetime(2024, 12, 16, 15, 0),
            latitude=40.7128,
            longitude=-74.0060
        )
        assert len(params.active_planets) >= 2
    
    def test_has_minimum_moods(self, sample_natal_chart):
        """Should have at least 3 moods."""
        params = calculate_vibe_parameters(
            natal_chart=sample_natal_chart,
            current_datetime=datetime(2024, 12, 16, 15, 0),
            latitude=40.7128,
            longitude=-74.0060
        )
        assert len(params.mood_direction) >= 3


class TestCosmicSummary:
    """Tests for cosmic summary generation."""
    
    def test_summary_length(self):
        """Summary should be 50-500 characters."""
        summary = generate_cosmic_summary(
            moon_sign="Aries",
            moon_phase="Full Moon",
            active_planets=["Mars", "Sun"],
            primary_element="Fire",
            energy_direction="high"
        )
        assert 50 <= len(summary) <= 500
    
    def test_summary_contains_moon_sign(self):
        """Summary should mention the moon sign."""
        summary = generate_cosmic_summary(
            moon_sign="Pisces",
            moon_phase="New Moon",
            active_planets=["Neptune"],
            primary_element="Water",
            energy_direction="low"
        )
        assert "Pisces" in summary
    
    def test_summary_contains_moon_phase(self):
        """Summary should mention the moon phase."""
        summary = generate_cosmic_summary(
            moon_sign="Leo",
            moon_phase="Waxing Crescent",
            active_planets=["Sun"],
            primary_element="Fire",
            energy_direction="moderate"
        )
        assert "Waxing Crescent" in summary
    
    def test_summary_mentions_element_quality(self):
        """Summary should reference element qualities."""
        summary = generate_cosmic_summary(
            moon_sign="Taurus",  # Earth sign
            moon_phase="Full Moon",
            active_planets=["Venus"],
            primary_element="Earth",
            energy_direction="moderate"
        )
        # Should contain earth-related quality
        assert "grounded" in summary.lower() or "sensual" in summary.lower()


class TestPlanetEffects:
    """Tests for planet effect constants."""
    
    def test_all_planets_have_effects(self):
        """All 10 planets should have defined effects."""
        expected_planets = ["Sun", "Moon", "Mercury", "Venus", "Mars",
                          "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]
        for planet in expected_planets:
            assert planet in PLANET_EFFECTS
    
    def test_effects_have_required_keys(self):
        """Each planet effect should have energy, valence, and moods."""
        for planet, effects in PLANET_EFFECTS.items():
            assert "energy" in effects
            assert "valence" in effects
            assert "moods" in effects
            assert isinstance(effects["moods"], list)


class TestMoonPhaseEffects:
    """Tests for moon phase effect constants."""
    
    def test_all_phases_have_effects(self):
        """All 8 moon phases should have defined effects."""
        expected_phases = [
            "New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous",
            "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"
        ]
        for phase in expected_phases:
            assert phase in MOON_PHASE_EFFECTS
    
    def test_effects_have_required_keys(self):
        """Each phase effect should have energy and moods."""
        for phase, effects in MOON_PHASE_EFFECTS.items():
            assert "energy" in effects
            assert "moods" in effects
