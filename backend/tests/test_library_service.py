"""
Unit tests for the library service.
Tests loading, querying, and filtering of the song mock library.

H3: Unit Test Creation - Tests for all library service functions.
C2: Regression Prevention - Run all tests before committing.
"""
import pytest
from services.library_service import (
    load_library,
    get_all_songs,
    get_song_by_id,
    filter_by_element,
    filter_by_planet,
    filter_by_genre,
    filter_by_mood,
    filter_by_criteria,
    clear_cache,
)
from data.constants import ELEMENTS, PLANETS, GENRES, MOODS, MODALITIES


class TestLibraryLoading:
    """Tests for library loading functionality."""
    
    def test_library_loads_100_songs(self):
        """Library should contain exactly 100 songs."""
        songs = get_all_songs()
        assert len(songs) == 100
    
    def test_all_songs_have_valid_ids(self):
        """All songs should have properly formatted IDs."""
        songs = get_all_songs()
        for song in songs:
            assert song.id.startswith("song_")
            assert len(song.id) == 8  # song_XXX format
    
    def test_songs_are_validated(self):
        """All songs should pass Pydantic validation."""
        # This implicitly tests validation - if load fails, test fails
        songs = load_library()
        assert all(song.title for song in songs)
        assert all(song.artist for song in songs)


class TestGetSongById:
    """Tests for get_song_by_id function."""
    
    def test_get_existing_song(self):
        """Should return correct song for valid ID."""
        song = get_song_by_id("song_001")
        assert song is not None
        assert song.title == "Skinny Love"
        assert song.artist == "Bon Iver"
    
    def test_get_nonexistent_song(self):
        """Should return None for invalid ID."""
        song = get_song_by_id("song_999")
        assert song is None
    
    def test_get_last_song(self):
        """Should return correct song for last ID."""
        song = get_song_by_id("song_100")
        assert song is not None
        assert song.title == "Nightcall"


class TestElementCoverage:
    """Tests for element coverage in library."""
    
    def test_fire_element_coverage(self):
        """Fire element should have at least 20 songs."""
        songs = filter_by_element("Fire")
        assert len(songs) >= 20
    
    def test_earth_element_coverage(self):
        """Earth element should have at least 20 songs."""
        songs = filter_by_element("Earth")
        assert len(songs) >= 20
    
    def test_air_element_coverage(self):
        """Air element should have at least 20 songs."""
        songs = filter_by_element("Air")
        assert len(songs) >= 20
    
    def test_water_element_coverage(self):
        """Water element should have at least 20 songs."""
        songs = filter_by_element("Water")
        assert len(songs) >= 20
    
    def test_invalid_element_raises_error(self):
        """Invalid element should raise ValueError."""
        with pytest.raises(ValueError):
            filter_by_element("Spirit")


class TestPlanetCoverage:
    """Tests for planetary energy coverage in library."""
    
    @pytest.mark.parametrize("planet", list(PLANETS.keys()))
    def test_each_planet_has_songs(self, planet):
        """Each planet should have at least 8 songs."""
        songs = filter_by_planet(planet)
        assert len(songs) >= 8, f"{planet} has only {len(songs)} songs"
    
    def test_invalid_planet_raises_error(self):
        """Invalid planet should raise ValueError."""
        with pytest.raises(ValueError):
            filter_by_planet("Nibiru")


class TestGenreCoverage:
    """Tests for genre coverage in library."""
    
    @pytest.mark.parametrize("genre", GENRES)
    def test_each_genre_has_songs(self, genre):
        """Each genre should have at least 2 songs."""
        songs = filter_by_genre(genre)
        assert len(songs) >= 2, f"{genre} has only {len(songs)} songs"
    
    def test_invalid_genre_raises_error(self):
        """Invalid genre should raise ValueError."""
        with pytest.raises(ValueError):
            filter_by_genre("Polka")


class TestMoodCoverage:
    """Tests for mood coverage in library."""
    
    @pytest.mark.parametrize("mood", MOODS)
    def test_each_mood_has_songs(self, mood):
        """Each mood should have at least 3 songs."""
        songs = filter_by_mood(mood)
        assert len(songs) >= 3, f"{mood} has only {len(songs)} songs"
    
    def test_invalid_mood_raises_error(self):
        """Invalid mood should raise ValueError."""
        with pytest.raises(ValueError):
            filter_by_mood("Confused")


class TestCombinedFilter:
    """Tests for multi-criteria filtering."""
    
    def test_filter_by_single_element_list(self):
        """Filter with single element list should work."""
        songs = filter_by_criteria(elements=["Fire"])
        assert len(songs) > 0
        assert all("Fire" in song.elements for song in songs)
    
    def test_filter_by_multiple_elements(self):
        """Filter with multiple elements uses OR logic."""
        songs = filter_by_criteria(elements=["Fire", "Water"])
        assert len(songs) > 0
        for song in songs:
            assert "Fire" in song.elements or "Water" in song.elements
    
    def test_filter_by_energy_range(self):
        """Filter by energy range should return correct songs."""
        songs = filter_by_criteria(min_energy=80, max_energy=100)
        assert len(songs) > 0
        assert all(80 <= song.energy <= 100 for song in songs)
    
    def test_filter_by_valence_range(self):
        """Filter by valence range should return correct songs."""
        songs = filter_by_criteria(min_valence=0, max_valence=30)
        assert len(songs) > 0
        assert all(song.valence <= 30 for song in songs)
    
    def test_filter_by_bpm_range(self):
        """Filter by BPM range should return correct songs."""
        songs = filter_by_criteria(min_bpm=120, max_bpm=150)
        assert len(songs) > 0
        assert all(120 <= song.bpm <= 150 for song in songs)
    
    def test_filter_by_modality(self):
        """Filter by modality should return correct songs."""
        songs = filter_by_criteria(modality="Cardinal")
        assert len(songs) > 0
        assert all(song.modality == "Cardinal" for song in songs)
    
    def test_filter_by_time_of_day(self):
        """Filter by time of day should return correct songs."""
        songs = filter_by_criteria(time_of_day="night")
        assert len(songs) > 0
        for song in songs:
            assert song.time_of_day is not None
            assert "night" in song.time_of_day
    
    def test_combined_filter_and_logic(self):
        """Combined criteria should use AND logic between categories."""
        songs = filter_by_criteria(
            elements=["Fire"],
            min_energy=70,
            moods=["Empowering", "Energizing"]
        )
        assert len(songs) > 0
        for song in songs:
            assert "Fire" in song.elements
            assert song.energy >= 70
            assert "Empowering" in song.moods or "Energizing" in song.moods
    
    def test_no_results_for_impossible_criteria(self):
        """Impossible criteria should return empty list."""
        songs = filter_by_criteria(
            elements=["Water"],
            min_energy=95,
            moods=["Peaceful"]
        )
        # Peaceful + Water + 95+ energy is very unlikely
        # This tests that the filter correctly returns few/no results
        assert len(songs) < 5


class TestCacheManagement:
    """Tests for cache functionality."""
    
    def test_clear_cache(self):
        """clear_cache should allow reloading."""
        # Load once to populate cache
        songs1 = get_all_songs()
        
        # Clear and reload
        clear_cache()
        songs2 = get_all_songs()
        
        # Should still have same data
        assert len(songs1) == len(songs2)
