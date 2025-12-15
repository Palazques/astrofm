"""
Unit tests for the AI service.
Tests environment variable loading, response parsing, and caching logic.
"""
import pytest
from unittest.mock import patch, MagicMock
from datetime import datetime, timezone, timedelta

from services.ai_service import AIService, CacheEntry


class TestEnvironmentLoading:
    """Tests for API key loading from environment."""
    
    def test_loads_gemini_key_from_env(self):
        """AIService should load GEMINI_API_KEY from environment."""
        with patch.dict('os.environ', {'GEMINI_API_KEY': 'test-gemini-key'}):
            with patch('services.ai_service.GEMINI_AVAILABLE', True):
                with patch('services.ai_service.genai') as mock_genai:
                    service = AIService()
                    assert service._gemini_key == 'test-gemini-key'
    
    def test_loads_openai_key_from_env(self):
        """AIService should load OPENAI_API_KEY from environment."""
        with patch.dict('os.environ', {'OPENAI_API_KEY': 'test-openai-key'}):
            with patch('services.ai_service.OPENAI_AVAILABLE', True):
                with patch('services.ai_service.OpenAI') as mock_openai:
                    service = AIService()
                    assert service._openai_key == 'test-openai-key'
    
    def test_handles_missing_keys_gracefully(self):
        """AIService should not crash if API keys are missing."""
        with patch.dict('os.environ', {}, clear=True):
            service = AIService()
            assert service._gemini_key is None
            assert service._openai_key is None


class TestResponseParsing:
    """Tests for AI response parsing logic."""
    
    def setup_method(self):
        """Set up test fixtures."""
        with patch.dict('os.environ', {}):
            self.service = AIService()
    
    def test_parses_prose_and_json(self):
        """Should correctly split prose and JSON from response."""
        response = '''Your cosmic energy is aligned with Mars today.
The warrior planet activates your 5th house of creativity.
{"bpm_min": 125, "bpm_max": 135, "energy": 0.8, "valence": 0.6, "genres": ["techno", "house"], "key_mode": "minor"}'''
        
        prose, params = self.service._parse_response(response)
        
        assert "Mars" in prose
        assert params["bpm_min"] == 125
        assert params["energy"] == 0.8
        assert "techno" in params["genres"]
    
    def test_returns_defaults_for_missing_json(self):
        """Should return default params if no JSON in response."""
        response = "Your cosmic energy is flowing freely today."
        
        prose, params = self.service._parse_response(response)
        
        assert prose == "Your cosmic energy is flowing freely today."
        assert params["bpm_min"] == 110  # default
        assert params["energy"] == 0.6  # default
    
    def test_handles_malformed_json(self):
        """Should use defaults if JSON is malformed."""
        response = '''Great vibes today!
{bpm_min: 120, not valid json}'''
        
        prose, params = self.service._parse_response(response)
        
        assert "Great vibes" in prose
        assert params["bpm_min"] == 110  # default, not 120
    
    def test_merges_partial_json_with_defaults(self):
        """Should merge partial JSON with defaults."""
        response = '''Mars is energizing!
{"bpm_min": 140, "energy": 0.9}'''
        
        prose, params = self.service._parse_response(response)
        
        assert params["bpm_min"] == 140
        assert params["energy"] == 0.9
        assert params["bpm_max"] == 130  # default
        assert params["valence"] == 0.5  # default


class TestCaching:
    """Tests for in-memory caching logic."""
    
    def setup_method(self):
        """Set up test fixtures."""
        with patch.dict('os.environ', {}):
            self.service = AIService()
    
    def test_cache_stores_data(self):
        """Cache should store and retrieve data."""
        self.service._set_cached("test-key", {"value": 123})
        
        result = self.service._get_cached("test-key")
        
        assert result == {"value": 123}
    
    def test_cache_returns_none_for_missing(self):
        """Cache should return None for missing keys."""
        result = self.service._get_cached("nonexistent")
        
        assert result is None
    
    def test_cache_respects_ttl(self):
        """Cache should expire entries after TTL."""
        # Set entry with very short TTL (already expired)
        entry = CacheEntry(
            data={"value": 456},
            expires_at=datetime.now(timezone.utc) - timedelta(seconds=1)
        )
        self.service._cache["expired-key"] = entry
        
        result = self.service._get_cached("expired-key")
        
        assert result is None
        assert "expired-key" not in self.service._cache
    
    def test_cache_no_ttl_never_expires(self):
        """Cache entries without TTL should never expire."""
        entry = CacheEntry(
            data={"value": 789},
            expires_at=None  # No TTL
        )
        self.service._cache["permanent-key"] = entry
        
        result = self.service._get_cached("permanent-key")
        
        assert result == {"value": 789}
    
    def test_generates_consistent_cache_keys(self):
        """Cache keys should be deterministic for same input."""
        data = {"a": 1, "b": 2}
        
        key1 = self.service._generate_cache_key("prefix", data)
        key2 = self.service._generate_cache_key("prefix", data)
        
        assert key1 == key2
    
    def test_different_data_produces_different_keys(self):
        """Different data should produce different cache keys."""
        key1 = self.service._generate_cache_key("prefix", {"a": 1})
        key2 = self.service._generate_cache_key("prefix", {"a": 2})
        
        assert key1 != key2


class TestAIProviderFallback:
    """Tests for Gemini -> OpenAI fallback logic."""
    
    def test_uses_gemini_when_available(self):
        """Should prefer Gemini when configured."""
        with patch.dict('os.environ', {'GEMINI_API_KEY': 'test-key'}):
            with patch('services.ai_service.GEMINI_AVAILABLE', True):
                with patch('services.ai_service.genai') as mock_genai:
                    mock_model = MagicMock()
                    mock_genai.GenerativeModel.return_value = mock_model
                    
                    service = AIService()
                    
                    assert service._gemini_model is not None
    
    def test_fallback_to_openai_on_gemini_failure(self):
        """Should fall back to OpenAI if Gemini fails."""
        with patch.dict('os.environ', {
            'GEMINI_API_KEY': 'test-gemini',
            'OPENAI_API_KEY': 'test-openai'
        }):
            with patch('services.ai_service.GEMINI_AVAILABLE', True):
                with patch('services.ai_service.OPENAI_AVAILABLE', True):
                    with patch('services.ai_service.genai') as mock_genai:
                        with patch('services.ai_service.OpenAI') as mock_openai_class:
                            # Make Gemini fail
                            mock_model = MagicMock()
                            mock_chat = MagicMock()
                            mock_chat.send_message.side_effect = Exception("Gemini error")
                            mock_model.start_chat.return_value = mock_chat
                            mock_genai.GenerativeModel.return_value = mock_model
                            
                            # OpenAI should work
                            mock_openai = MagicMock()
                            mock_response = MagicMock()
                            mock_response.choices = [MagicMock(message=MagicMock(content="OpenAI response"))]
                            mock_openai.chat.completions.create.return_value = mock_response
                            mock_openai_class.return_value = mock_openai
                            
                            service = AIService()
                            result = service._generate_response("test prompt")
                            
                            assert result == "OpenAI response"
