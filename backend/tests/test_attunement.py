"""
Unit tests for the attunement calculation service.
Tests gap detection, resonance matching, and weekly digest generation.
"""
import pytest
from datetime import datetime, timezone

from services.attunement import (
    calculate_attunement,
    get_weekly_digest,
    _calculate_intensity_gap,
    _determine_status,
    GAP_THRESHOLD,
    RESONANCE_THRESHOLD,
    MAX_GAPS_PER_DAY,
    LOW_ALIGNMENT_THRESHOLD,
)
from models.attunement_schemas import AttunementAnalysis, PlanetAttunement


class TestIntensityGap:
    """Tests for intensity gap calculation."""
    
    def test_positive_gap_when_transit_stronger(self):
        """Gap should be positive when transit exceeds natal."""
        gap = _calculate_intensity_gap(0.3, 0.8)
        assert gap == pytest.approx(0.5, abs=0.01)
    
    def test_negative_gap_when_natal_stronger(self):
        """Gap should be negative when natal exceeds transit."""
        gap = _calculate_intensity_gap(0.8, 0.3)
        assert gap == pytest.approx(-0.5, abs=0.01)
    
    def test_zero_gap_when_equal(self):
        """Gap should be zero when intensities match."""
        gap = _calculate_intensity_gap(0.5, 0.5)
        assert gap == 0.0


class TestStatusDetermination:
    """Tests for gap/resonance status determination."""
    
    def test_gap_status_when_large_difference_different_house(self):
        """Should be 'gap' when transit much stronger and different house."""
        status = _determine_status(gap=0.5, natal_house=3, transit_house=7)
        assert status == "gap"
    
    def test_not_gap_when_same_house(self):
        """Should NOT be 'gap' even with large difference if same house."""
        status = _determine_status(gap=0.5, natal_house=5, transit_house=5)
        assert status != "gap"
    
    def test_resonance_when_close_same_house(self):
        """Should be 'resonance' when intensities close and same house."""
        status = _determine_status(gap=0.1, natal_house=4, transit_house=4)
        assert status == "resonance"
    
    def test_resonance_when_close_trine_houses(self):
        """Should be 'resonance' when intensities close and trine houses."""
        # Houses 4 apart are in trine
        status = _determine_status(gap=0.1, natal_house=1, transit_house=5)
        assert status == "resonance"
    
    def test_neutral_when_neither_gap_nor_resonance(self):
        """Should be 'neutral' when conditions for gap/resonance not met."""
        # Small gap but different house (not compatible - houses 2 and 3 are 1 apart)
        status = _determine_status(gap=0.25, natal_house=2, transit_house=3)
        assert status == "neutral"


class TestGapDetection:
    """Tests for gap detection in attunement analysis."""
    
    # Test birth data
    TEST_BIRTH = datetime(1990, 7, 15, 15, 42)
    TEST_LAT = 34.0522
    TEST_LON = -118.2437
    
    def test_returns_attunement_analysis(self):
        """Should return valid AttunementAnalysis object."""
        result = calculate_attunement(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        assert isinstance(result, AttunementAnalysis)
    
    def test_has_required_fields(self):
        """Analysis should have all required fields."""
        result = calculate_attunement(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        assert hasattr(result, 'planets')
        assert hasattr(result, 'gaps')
        assert hasattr(result, 'resonances')
        assert hasattr(result, 'alignment_score')
    
    def test_limits_gaps_to_max(self):
        """Should return at most MAX_GAPS_PER_DAY gaps."""
        result = calculate_attunement(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        assert len(result.gaps) <= MAX_GAPS_PER_DAY
    
    def test_gaps_are_prioritized(self):
        """Gaps should be sorted by priority (most severe first)."""
        result = calculate_attunement(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        if len(result.gaps) > 1:
            # First gap should have higher intensity_gap than second
            assert result.gaps[0].intensity_gap >= result.gaps[1].intensity_gap
    
    def test_alignment_score_in_valid_range(self):
        """Alignment score should be 0-100."""
        result = calculate_attunement(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        assert 0 <= result.alignment_score <= 100


class TestResonanceDetection:
    """Tests for resonance detection in attunement analysis."""
    
    TEST_BIRTH = datetime(1990, 7, 15, 15, 42)
    TEST_LAT = 34.0522
    TEST_LON = -118.2437
    
    def test_resonances_have_status_resonance(self):
        """All items in resonances list should have status 'resonance'."""
        result = calculate_attunement(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        for res in result.resonances:
            assert res.status == "resonance"
    
    def test_resonances_have_small_gap(self):
        """Resonances should have intensity gap within threshold."""
        result = calculate_attunement(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        for res in result.resonances:
            assert abs(res.intensity_gap) <= RESONANCE_THRESHOLD


class TestNotificationTriggers:
    """Tests for notification trigger logic."""
    
    TEST_BIRTH = datetime(1990, 7, 15, 15, 42)
    TEST_LAT = 34.0522
    TEST_LON = -118.2437
    
    def test_should_notify_has_reason_when_true(self):
        """When should_notify is True, notification_reason should be set."""
        result = calculate_attunement(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        if result.should_notify:
            assert result.notification_reason is not None


class TestWeeklyDigest:
    """Tests for weekly digest generation."""
    
    TEST_BIRTH = datetime(1990, 7, 15, 15, 42)
    TEST_LAT = 34.0522
    TEST_LON = -118.2437
    
    def test_returns_weekly_digest(self):
        """Should return valid WeeklyDigest object."""
        result = get_weekly_digest(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        from models.attunement_schemas import WeeklyDigest
        assert isinstance(result, WeeklyDigest)
    
    def test_has_required_fields(self):
        """Digest should have all required fields."""
        result = get_weekly_digest(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        assert hasattr(result, 'week_start')
        assert hasattr(result, 'week_end')
        assert hasattr(result, 'average_alignment')
        assert hasattr(result, 'best_day')
        assert hasattr(result, 'challenging_day')
    
    def test_average_in_valid_range(self):
        """Average alignment should be 0-100."""
        result = get_weekly_digest(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        assert 0 <= result.average_alignment <= 100
    
    def test_common_gaps_are_planets(self):
        """Common gaps should be valid planet names."""
        result = get_weekly_digest(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        valid_planets = [
            "Sun", "Moon", "Mercury", "Venus", "Mars",
            "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"
        ]
        for planet in result.common_gaps:
            assert planet in valid_planets


class TestPlanetAttunementExplanations:
    """Tests for explanation generation."""
    
    TEST_BIRTH = datetime(1990, 7, 15, 15, 42)
    TEST_LAT = 34.0522
    TEST_LON = -118.2437
    
    def test_all_planets_have_explanations(self):
        """Every planet in analysis should have an explanation."""
        result = calculate_attunement(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        for planet in result.planets:
            assert planet.explanation != ""
    
    def test_gap_explanations_mention_attune(self):
        """Gap explanations should mention 'attune'."""
        result = calculate_attunement(
            birth_datetime=self.TEST_BIRTH,
            latitude=self.TEST_LAT,
            longitude=self.TEST_LON
        )
        for gap in result.gaps:
            assert "attune" in gap.explanation.lower() or "Attune" in gap.explanation
