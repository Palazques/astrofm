"""
Unit tests for the transit alignment calculation service.
Tests gap/resonance determination, insight retrieval, and alignment calculations.
"""
import pytest
from datetime import datetime

from services.transit_alignment import (
    determine_gap_or_resonance,
    get_planet_insight,
    calculate_transit_alignment,
    HOUSE_THEMES,
    PLANET_SYMBOLS,
    PLANET_COLORS,
    TRANSIT_INSIGHTS,
)


class TestGapResonanceDetermination:
    """Tests for gap vs resonance determination logic."""
    
    def test_same_house_is_resonance(self):
        """Same natal and transit house should be resonance."""
        status = determine_gap_or_resonance(
            natal_house=5,
            transit_house=5,
            natal_lon=120.0,
            transit_lon=125.0,
        )
        assert status == "resonance"
    
    def test_adjacent_house_is_resonance(self):
        """Adjacent houses (distance 1) should be resonance."""
        status = determine_gap_or_resonance(
            natal_house=5,
            transit_house=6,
            natal_lon=120.0,
            transit_lon=150.0,
        )
        assert status == "resonance"
    
    def test_distant_house_is_gap(self):
        """Houses 4+ apart should be gap."""
        status = determine_gap_or_resonance(
            natal_house=1,
            transit_house=7,
            natal_lon=15.0,
            transit_lon=195.0,
        )
        assert status == "gap"
    
    def test_house_12_to_1_is_adjacent(self):
        """House 12 to 1 should be considered adjacent (circular)."""
        status = determine_gap_or_resonance(
            natal_house=12,
            transit_house=1,
            natal_lon=350.0,
            transit_lon=10.0,
        )
        # Should be resonance due to adjacent houses
        assert status == "resonance"
    
    def test_trine_aspect_is_resonance(self):
        """Trine (120°) aspect should be resonance regardless of houses."""
        status = determine_gap_or_resonance(
            natal_house=1,
            transit_house=5,  # Distance 4, normally gap
            natal_lon=0.0,
            transit_lon=120.0,  # Exact trine
        )
        assert status == "resonance"
    
    def test_square_aspect_is_gap(self):
        """Square (90°) aspect should be gap."""
        status = determine_gap_or_resonance(
            natal_house=1,
            transit_house=4,
            natal_lon=0.0,
            transit_lon=90.0,  # Exact square
        )
        assert status == "gap"
    
    def test_opposition_aspect_is_gap(self):
        """Opposition (180°) aspect should be gap."""
        status = determine_gap_or_resonance(
            natal_house=1,
            transit_house=7,
            natal_lon=0.0,
            transit_lon=180.0,
        )
        assert status == "gap"


class TestPlanetInsight:
    """Tests for planet-specific insight retrieval."""
    
    def test_returns_placeholder_when_no_content(self):
        """Should return placeholder insight when no specific content exists."""
        insight = get_planet_insight("sun", 5, 10)
        
        assert "pull" in insight
        assert "feelings" in insight
        assert "practice" in insight
        assert len(insight["feelings"]) >= 2
    
    def test_placeholder_contains_house_themes(self):
        """Placeholder insight should reference house themes."""
        insight = get_planet_insight("moon", 4, 8)
        
        natal_theme = HOUSE_THEMES[4]  # Foundation
        transit_theme = HOUSE_THEMES[8]  # Depths
        
        assert natal_theme in insight["pull"] or natal_theme.lower() in insight["pull"].lower()
    
    def test_case_insensitive_planet_names(self):
        """Planet names should be case-insensitive."""
        insight1 = get_planet_insight("Sun", 1, 7)
        insight2 = get_planet_insight("sun", 1, 7)
        
        # Both should return valid insights (not errors)
        assert "pull" in insight1
        assert "pull" in insight2
    
    def test_insight_structure_valid(self):
        """Returned insight should have correct structure."""
        for planet in ["sun", "moon", "mercury", "venus", "mars"]:
            insight = get_planet_insight(planet, 1, 12)
            
            assert isinstance(insight["pull"], str)
            assert isinstance(insight["feelings"], list)
            assert isinstance(insight["practice"], str)
            assert len(insight["pull"]) > 0
            assert len(insight["practice"]) > 0


class TestTransitInsightsStructure:
    """Tests for the TRANSIT_INSIGHTS data structure."""
    
    def test_has_all_planets(self):
        """TRANSIT_INSIGHTS should have entries for all 10 planets."""
        expected_planets = [
            "sun", "moon", "mercury", "venus", "mars",
            "jupiter", "saturn", "uranus", "neptune", "pluto"
        ]
        
        for planet in expected_planets:
            assert planet in TRANSIT_INSIGHTS, f"Missing planet: {planet}"
    
    def test_planet_entries_are_dicts(self):
        """Each planet entry should be a dict for house combinations."""
        for planet, combos in TRANSIT_INSIGHTS.items():
            assert isinstance(combos, dict), f"{planet} should have dict value"


class TestPlanetMetadata:
    """Tests for planet symbols and colors."""
    
    def test_all_planets_have_symbols(self):
        """All major planets should have symbols."""
        expected = ["Sun", "Moon", "Mercury", "Venus", "Mars",
                    "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]
        
        for planet in expected:
            assert planet in PLANET_SYMBOLS
            assert len(PLANET_SYMBOLS[planet]) > 0
    
    def test_all_planets_have_colors(self):
        """All major planets should have colors."""
        expected = ["Sun", "Moon", "Mercury", "Venus", "Mars",
                    "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]
        
        for planet in expected:
            assert planet in PLANET_COLORS
            assert PLANET_COLORS[planet].startswith("#")


class TestHouseThemes:
    """Tests for house theme data."""
    
    def test_all_12_houses_present(self):
        """All 12 houses should have themes."""
        for house in range(1, 13):
            assert house in HOUSE_THEMES
    
    def test_themes_are_strings(self):
        """House themes should be non-empty strings."""
        for house, theme in HOUSE_THEMES.items():
            assert isinstance(theme, str)
            assert len(theme) > 0


class TestCalculateTransitAlignment:
    """Integration tests for full alignment calculation."""
    
    def test_returns_all_planets(self):
        """Should return alignment data for all 10 planets."""
        result = calculate_transit_alignment(
            birth_datetime="1990-07-15T15:42:00",
            latitude=34.0522,
            longitude=-118.2437,
            timezone_str="America/Los_Angeles",
        )
        
        assert len(result["planets"]) == 10
    
    def test_returns_gap_and_resonance_counts(self):
        """Should return counts of gaps and resonances."""
        result = calculate_transit_alignment(
            birth_datetime="1990-07-15T15:42:00",
            latitude=34.0522,
            longitude=-118.2437,
            timezone_str="America/Los_Angeles",
        )
        
        assert "gap_count" in result
        assert "resonance_count" in result
        assert result["gap_count"] + result["resonance_count"] == 10
    
    def test_planet_data_structure(self):
        """Each planet should have required fields."""
        result = calculate_transit_alignment(
            birth_datetime="1990-07-15T15:42:00",
            latitude=34.0522,
            longitude=-118.2437,
            timezone_str="America/Los_Angeles",
        )
        
        for planet in result["planets"]:
            assert "id" in planet
            assert "name" in planet
            assert "symbol" in planet
            assert "color" in planet
            assert "natal" in planet
            assert "transit" in planet
            assert "status" in planet
            assert "pull" in planet
            assert "feelings" in planet
            assert "practice" in planet
    
    def test_natal_position_structure(self):
        """Natal position should have sign, degree, house."""
        result = calculate_transit_alignment(
            birth_datetime="1990-07-15T15:42:00",
            latitude=34.0522,
            longitude=-118.2437,
            timezone_str="America/Los_Angeles",
        )
        
        for planet in result["planets"]:
            natal = planet["natal"]
            assert "sign" in natal
            assert "degree" in natal
            assert "house" in natal
            assert 1 <= natal["house"] <= 12
    
    def test_transit_position_structure(self):
        """Transit position should have sign, degree, house, retrograde."""
        result = calculate_transit_alignment(
            birth_datetime="1990-07-15T15:42:00",
            latitude=34.0522,
            longitude=-118.2437,
            timezone_str="America/Los_Angeles",
        )
        
        for planet in result["planets"]:
            transit = planet["transit"]
            assert "sign" in transit
            assert "degree" in transit
            assert "house" in transit
            assert "retrograde" in transit
            assert isinstance(transit["retrograde"], bool)
    
    def test_status_is_gap_or_resonance(self):
        """Status should be either 'gap' or 'resonance'."""
        result = calculate_transit_alignment(
            birth_datetime="1990-07-15T15:42:00",
            latitude=34.0522,
            longitude=-118.2437,
            timezone_str="America/Los_Angeles",
        )
        
        for planet in result["planets"]:
            assert planet["status"] in ["gap", "resonance"]
