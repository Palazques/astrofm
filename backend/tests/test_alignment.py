"""
Unit tests for the alignment calculation service.
Tests aspect detection, scoring algorithm, and alignment calculations.
"""
import pytest
from datetime import datetime

from services.alignment import (
    normalize_angle,
    calculate_angular_distance,
    detect_aspect,
    detect_all_aspects,
    calculate_aspect_score,
    determine_dominant_energy,
    get_moon_phase,
    get_current_transits,
    calculate_daily_alignment,
    MAJOR_ORB,
    MINOR_ORB,
)


class TestAngleCalculations:
    """Tests for angle helper functions."""
    
    def test_normalize_angle_positive(self):
        """Positive angle within range should stay the same."""
        assert normalize_angle(90) == 90
    
    def test_normalize_angle_negative(self):
        """Negative angle should wrap to positive."""
        assert normalize_angle(-90) == 270
    
    def test_normalize_angle_over_360(self):
        """Angle over 360 should wrap around."""
        assert normalize_angle(450) == 90
    
    def test_angular_distance_simple(self):
        """Simple distance calculation."""
        assert calculate_angular_distance(0, 90) == 90
    
    def test_angular_distance_across_zero(self):
        """Distance should take shortest path across 0/360."""
        # 350° to 10° is 20°, not 340°
        assert calculate_angular_distance(350, 10) == 20


class TestAspectDetection:
    """Tests for aspect detection logic."""
    
    def test_conjunction_exact(self):
        """Exact conjunction should be detected."""
        aspect = detect_aspect(0, 0, "Sun", "Moon")
        assert aspect is not None
        assert aspect["aspect"] == "Conjunction"
        assert aspect["orb"] == 0
    
    def test_conjunction_within_orb(self):
        """Conjunction within 8° orb should be detected."""
        aspect = detect_aspect(0, 6, "Sun", "Moon")
        assert aspect is not None
        assert aspect["aspect"] == "Conjunction"
        assert aspect["orb"] == 6
    
    def test_conjunction_outside_orb(self):
        """Conjunction outside 8° orb should not be detected."""
        aspect = detect_aspect(0, 10, "Sun", "Moon")
        # Should not be a conjunction, might be another aspect or None
        if aspect:
            assert aspect["aspect"] != "Conjunction"
    
    def test_trine_detection(self):
        """Trine (120°) should be detected within orb."""
        aspect = detect_aspect(0, 122, "Sun", "Moon")
        assert aspect is not None
        assert aspect["aspect"] == "Trine"
        assert aspect["nature"] == "harmonious"
    
    def test_square_detection(self):
        """Square (90°) should be detected."""
        aspect = detect_aspect(0, 88, "Sun", "Moon")
        assert aspect is not None
        assert aspect["aspect"] == "Square"
        assert aspect["nature"] == "challenging"
    
    def test_opposition_detection(self):
        """Opposition (180°) should be detected."""
        aspect = detect_aspect(0, 178, "Sun", "Moon")
        assert aspect is not None
        assert aspect["aspect"] == "Opposition"
        assert aspect["nature"] == "challenging"
    
    def test_sextile_detection(self):
        """Sextile (60°) should be detected."""
        aspect = detect_aspect(0, 62, "Sun", "Moon")
        assert aspect is not None
        assert aspect["aspect"] == "Sextile"
        assert aspect["nature"] == "harmonious"
    
    def test_minor_aspect_quincunx(self):
        """Quincunx (150°) with 3° orb should be detected."""
        aspect = detect_aspect(0, 151, "Sun", "Moon")
        assert aspect is not None
        assert aspect["aspect"] == "Quincunx"
    
    def test_minor_aspect_outside_orb(self):
        """Minor aspect outside 3° orb should not be detected."""
        # 155° is 5° away from 150° quincunx, outside 3° orb
        aspect = detect_aspect(0, 155, "Sun", "Moon")
        # Should not detect quincunx
        if aspect:
            assert aspect["aspect"] != "Quincunx"
    
    def test_conjunction_with_benefic(self):
        """Conjunction with Venus should be harmonious."""
        aspect = detect_aspect(0, 2, "Sun", "Venus")
        assert aspect is not None
        assert aspect["aspect"] == "Conjunction"
        assert aspect["nature"] == "harmonious"
    
    def test_conjunction_with_malefic(self):
        """Conjunction with Mars should be challenging."""
        aspect = detect_aspect(0, 2, "Sun", "Mars")
        assert aspect is not None
        assert aspect["aspect"] == "Conjunction"
        assert aspect["nature"] == "challenging"


class TestAspectScoring:
    """Tests for aspect score calculation."""
    
    def test_harmonious_aspect_positive_score(self):
        """Harmonious aspects should give positive score."""
        aspect = {
            "planet1": "Natal Sun",
            "planet2": "Transit Moon",
            "aspect": "Trine",
            "orb": 2.0,
            "nature": "harmonious"
        }
        score = calculate_aspect_score(aspect)
        assert score > 0
    
    def test_tighter_orb_higher_score(self):
        """Tighter orbs should give higher scores."""
        aspect_tight = {
            "planet1": "Natal Sun",
            "planet2": "Transit Moon",
            "aspect": "Trine",
            "orb": 1.0,
            "nature": "harmonious"
        }
        aspect_wide = {
            "planet1": "Natal Sun",
            "planet2": "Transit Moon",
            "aspect": "Trine",
            "orb": 7.0,
            "nature": "harmonious"
        }
        assert calculate_aspect_score(aspect_tight) > calculate_aspect_score(aspect_wide)
    
    def test_sun_moon_weighted_higher(self):
        """Sun/Moon aspects should score higher than outer planet aspects."""
        aspect_luminaries = {
            "planet1": "Natal Sun",
            "planet2": "Transit Moon",
            "aspect": "Trine",
            "orb": 3.0,
            "nature": "harmonious"
        }
        aspect_outer = {
            "planet1": "Natal Neptune",
            "planet2": "Transit Pluto",
            "aspect": "Trine",
            "orb": 3.0,
            "nature": "harmonious"
        }
        assert calculate_aspect_score(aspect_luminaries) > calculate_aspect_score(aspect_outer)
    
    def test_challenging_aspect_still_positive(self):
        """Challenging aspects should still give positive score (complexity)."""
        aspect = {
            "planet1": "Natal Sun",
            "planet2": "Transit Saturn",
            "aspect": "Square",
            "orb": 2.0,
            "nature": "challenging"
        }
        score = calculate_aspect_score(aspect)
        assert score > 0


class TestMoonPhase:
    """Tests for moon phase calculation."""
    
    def test_new_moon(self):
        """Sun and Moon at same degree should be New Moon."""
        phase = get_moon_phase(0, 0)
        assert phase == "New Moon"
    
    def test_full_moon(self):
        """Sun and Moon opposite should be Full Moon."""
        phase = get_moon_phase(0, 180)
        assert phase == "Full Moon"
    
    def test_first_quarter(self):
        """Moon 90° ahead of Sun should be First Quarter."""
        phase = get_moon_phase(0, 100)
        assert phase == "First Quarter"
    
    def test_waxing_crescent(self):
        """Moon 45-90° ahead should be Waxing Crescent."""
        phase = get_moon_phase(0, 60)
        assert phase == "Waxing Crescent"


class TestDominantEnergy:
    """Tests for dominant energy determination."""
    
    def test_harmonious_majority(self):
        """Mostly harmonious aspects should give Harmonious energy."""
        aspects = [
            {"nature": "harmonious", "planet1": "Sun", "planet2": "Moon"},
            {"nature": "harmonious", "planet1": "Venus", "planet2": "Jupiter"},
            {"nature": "harmonious", "planet1": "Mercury", "planet2": "Venus"},
            {"nature": "challenging", "planet1": "Mars", "planet2": "Saturn"},
        ]
        energy = determine_dominant_energy(aspects)
        assert energy == "Harmonious"
    
    def test_pluto_gives_transformative(self):
        """Multiple Pluto aspects should give Transformative energy."""
        aspects = [
            {"nature": "challenging", "planet1": "Sun", "planet2": "Pluto"},
            {"nature": "harmonious", "planet1": "Moon", "planet2": "Pluto"},
            {"nature": "neutral", "planet1": "Venus", "planet2": "Mars"},
        ]
        energy = determine_dominant_energy(aspects)
        assert energy == "Transformative"
    
    def test_empty_aspects_balanced(self):
        """No aspects should return Balanced."""
        energy = determine_dominant_energy([])
        assert energy == "Balanced"


class TestCurrentTransits:
    """Tests for getting current transits."""
    
    def test_returns_all_planets(self):
        """Should return positions for all 10 major planets."""
        transits = get_current_transits()
        expected_planets = [
            "Sun", "Moon", "Mercury", "Venus", "Mars",
            "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"
        ]
        planet_names = [t["name"] for t in transits]
        for planet in expected_planets:
            assert planet in planet_names
    
    def test_transit_has_required_fields(self):
        """Each transit should have all required fields."""
        transits = get_current_transits()
        for transit in transits:
            assert "name" in transit
            assert "longitude" in transit
            assert "sign" in transit
            assert "sign_degree" in transit
            assert "retrograde" in transit
    
    def test_longitude_in_valid_range(self):
        """Longitudes should be 0-360."""
        transits = get_current_transits()
        for transit in transits:
            assert 0 <= transit["longitude"] < 360


class TestDailyAlignment:
    """Tests for daily alignment calculation."""
    
    def test_returns_valid_score(self):
        """Should return score between 0-100."""
        mock_chart = {
            "planets": [
                {"name": "Sun", "longitude": 0, "house": 1},
                {"name": "Moon", "longitude": 120, "house": 5},
            ]
        }
        result = calculate_daily_alignment(mock_chart)
        assert 0 <= result["score"] <= 100
    
    def test_returns_required_fields(self):
        """Should return all required response fields."""
        mock_chart = {
            "planets": [
                {"name": "Sun", "longitude": 0, "house": 1},
            ]
        }
        result = calculate_daily_alignment(mock_chart)
        assert "score" in result
        assert "aspects" in result
        assert "dominant_energy" in result
        assert "description" in result
    
    def test_different_charts_different_scores(self):
        """Different natal chart positions should give different results."""
        chart1 = {
            "planets": [
                {"name": "Sun", "longitude": 0, "house": 1},
                {"name": "Moon", "longitude": 30, "house": 2},
            ]
        }
        chart2 = {
            "planets": [
                {"name": "Sun", "longitude": 180, "house": 7},
                {"name": "Moon", "longitude": 270, "house": 10},
            ]
        }
        result1 = calculate_daily_alignment(chart1)
        result2 = calculate_daily_alignment(chart2)
        # Different charts should likely produce different aspect counts
        # (scores might coincidentally match, but aspect patterns should differ)
        assert (
            result1["score"] != result2["score"] or
            len(result1["aspects"]) != len(result2["aspects"])
        )
