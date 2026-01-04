import 'package:flutter/material.dart';

/// Static reference data for astrological synastry calculations.
/// Based on traditional astrology principles for compatibility analysis.

// =============================================================================
// SIGN COLORS
// =============================================================================

/// Gradient colors for each zodiac sign, derived from elemental associations.
const Map<String, Map<String, int>> signColors = {
  'Aries':       {'color1': 0xFFE84855, 'color2': 0xFFFF6B6B},
  'Taurus':      {'color1': 0xFF00D4AA, 'color2': 0xFF2ECC71},
  'Gemini':      {'color1': 0xFFFAFF0E, 'color2': 0xFFF1C40F},
  'Cancer':      {'color1': 0xFFC0C0C0, 'color2': 0xFF8A9BA8},
  'Leo':         {'color1': 0xFFFF8C42, 'color2': 0xFFF39C12},
  'Virgo':       {'color1': 0xFF00D4AA, 'color2': 0xFF1ABC9C},
  'Libra':       {'color1': 0xFFFF59D0, 'color2': 0xFFE91E8C},
  'Scorpio':     {'color1': 0xFF7D67FE, 'color2': 0xFF9B59B6},
  'Sagittarius': {'color1': 0xFFE84855, 'color2': 0xFFC0392B},
  'Capricorn':   {'color1': 0xFF8B7355, 'color2': 0xFF6C5B4C},
  'Aquarius':    {'color1': 0xFF7DD3FC, 'color2': 0xFF3498DB},
  'Pisces':      {'color1': 0xFF7D67FE, 'color2': 0xFF8E44AD},
};

// =============================================================================
// ELEMENT DATA
// =============================================================================

/// Element associations with signs, symbols, and colors.
class ElementData {
  final List<String> signs;
  final String symbol;
  final int colorValue;
  
  const ElementData({
    required this.signs,
    required this.symbol,
    required this.colorValue,
  });
  
  Color get color => Color(colorValue);
}

const Map<String, ElementData> elements = {
  'Fire':  ElementData(signs: ['Aries', 'Leo', 'Sagittarius'], symbol: '🔥', colorValue: 0xFFE84855),
  'Earth': ElementData(signs: ['Taurus', 'Virgo', 'Capricorn'], symbol: '🌍', colorValue: 0xFF00D4AA),
  'Air':   ElementData(signs: ['Gemini', 'Libra', 'Aquarius'], symbol: '💨', colorValue: 0xFF7DD3FC),
  'Water': ElementData(signs: ['Cancer', 'Scorpio', 'Pisces'], symbol: '💧', colorValue: 0xFF00B4D8),
};

/// Element compatibility matrix.
class ElementCompatibility {
  final String compatibility; // 'same', 'compatible', 'neutral', 'challenging'
  final String meaning;
  
  const ElementCompatibility({required this.compatibility, required this.meaning});
}

const Map<String, ElementCompatibility> elementCompatibility = {
  // Same element - deep understanding
  'Fire-Fire':   ElementCompatibility(compatibility: 'same', meaning: 'Passionate kindred spirits'),
  'Earth-Earth': ElementCompatibility(compatibility: 'same', meaning: 'Grounded understanding'),
  'Air-Air':     ElementCompatibility(compatibility: 'same', meaning: 'Mental wavelength match'),
  'Water-Water': ElementCompatibility(compatibility: 'same', meaning: 'Intuitive understanding'),
  
  // Compatible elements (Fire-Air, Earth-Water)
  'Fire-Air':    ElementCompatibility(compatibility: 'compatible', meaning: 'You fuel each other\'s spark'),
  'Air-Fire':    ElementCompatibility(compatibility: 'compatible', meaning: 'Ideas ignite into action'),
  'Earth-Water': ElementCompatibility(compatibility: 'compatible', meaning: 'Nurturing stability'),
  'Water-Earth': ElementCompatibility(compatibility: 'compatible', meaning: 'Emotions find form'),
  
  // Neutral (same modality tendency)
  'Fire-Earth':  ElementCompatibility(compatibility: 'neutral', meaning: 'Different speeds, mutual respect'),
  'Earth-Fire':  ElementCompatibility(compatibility: 'neutral', meaning: 'Grounding meets inspiration'),
  'Air-Water':   ElementCompatibility(compatibility: 'neutral', meaning: 'Logic meets intuition'),
  'Water-Air':   ElementCompatibility(compatibility: 'neutral', meaning: 'Feeling meets thinking'),
  
  // Challenging (square elements)
  'Fire-Water':  ElementCompatibility(compatibility: 'challenging', meaning: 'Steam - intense transformation'),
  'Water-Fire':  ElementCompatibility(compatibility: 'challenging', meaning: 'Emotions test willpower'),
  'Earth-Air':   ElementCompatibility(compatibility: 'challenging', meaning: 'Practicality meets abstraction'),
  'Air-Earth':   ElementCompatibility(compatibility: 'challenging', meaning: 'Ideas seek grounding'),
};

// =============================================================================
// ASPECT DATA
// =============================================================================

/// Astrological aspect definitions.
class AspectData {
  final String symbol;
  final int degrees;
  final int orb;
  final String quality; // 'harmonious', 'tense', 'intense'
  final int colorValue;
  final String description;
  
  const AspectData({
    required this.symbol,
    required this.degrees,
    required this.orb,
    required this.quality,
    required this.colorValue,
    required this.description,
  });
  
  Color get color => Color(colorValue);
}

const Map<String, AspectData> aspects = {
  'Conjunction': AspectData(
    symbol: '☌', degrees: 0, orb: 8,
    quality: 'intense', colorValue: 0xFFFAFF0E,
    description: 'merges with',
  ),
  'Sextile': AspectData(
    symbol: '⚹', degrees: 60, orb: 6,
    quality: 'harmonious', colorValue: 0xFF00D4AA,
    description: 'supports',
  ),
  'Square': AspectData(
    symbol: '□', degrees: 90, orb: 8,
    quality: 'tense', colorValue: 0xFFE84855,
    description: 'challenges',
  ),
  'Trine': AspectData(
    symbol: '△', degrees: 120, orb: 8,
    quality: 'harmonious', colorValue: 0xFF00D4AA,
    description: 'flows with',
  ),
  'Opposition': AspectData(
    symbol: '☍', degrees: 180, orb: 8,
    quality: 'tense', colorValue: 0xFFE84855,
    description: 'balances',
  ),
};

/// Quality colors for UI.
const Map<String, int> qualityColors = {
  'harmonious': 0xFF00D4AA,
  'tense': 0xFFE84855,
  'intense': 0xFFFAFF0E,
};

// =============================================================================
// PLANET DATA
// =============================================================================

/// Planet symbols and frequencies.
class PlanetData {
  final String symbol;
  final int frequency;
  final int colorValue;
  
  const PlanetData({
    required this.symbol,
    required this.frequency,
    required this.colorValue,
  });
  
  Color get color => Color(colorValue);
}

const Map<String, PlanetData> planets = {
  'Sun':     PlanetData(symbol: '☉', frequency: 126, colorValue: 0xFFFAFF0E),
  'Moon':    PlanetData(symbol: '☽', frequency: 210, colorValue: 0xFFC0C0C0),
  'Mercury': PlanetData(symbol: '☿', frequency: 141, colorValue: 0xFF7DD3FC),
  'Venus':   PlanetData(symbol: '♀', frequency: 221, colorValue: 0xFFFF59D0),
  'Mars':    PlanetData(symbol: '♂', frequency: 145, colorValue: 0xFFE84855),
  'Jupiter': PlanetData(symbol: '♃', frequency: 184, colorValue: 0xFFFF8C42),
  'Saturn':  PlanetData(symbol: '♄', frequency: 148, colorValue: 0xFF8B7355),
  'Uranus':  PlanetData(symbol: '♅', frequency: 207, colorValue: 0xFF00D4AA),
  'Neptune': PlanetData(symbol: '♆', frequency: 211, colorValue: 0xFF7D67FE),
  'Pluto':   PlanetData(symbol: '♇', frequency: 140, colorValue: 0xFF9D4EDD),
};

/// Priority order for synastry planet analysis.
const List<String> priorityPlanets = [
  'Sun', 'Moon', 'Venus', 'Mars', 'Mercury', 
  'Jupiter', 'Saturn', 'Pluto', 'Neptune', 'Uranus'
];

// =============================================================================
// SYNASTRY MEANINGS
// =============================================================================

/// Interpretations for planet-pair aspects in synastry.
const Map<String, Map<String, String>> synastryMeanings = {
  'harmonious': {
    'Moon-Moon': 'Emotional attunement runs deep',
    'Moon-Pluto': 'Deep emotional transformation together',
    'Moon-Sun': 'Their emotions nurture your identity',
    'Moon-Venus': 'Tender emotional connection',
    'Moon-Mars': 'Feelings and actions align naturally',
    'Moon-Jupiter': 'Emotional generosity flows',
    'Sun-Sun': 'Your core identities naturally understand each other',
    'Sun-Venus': 'Natural attraction and appreciation',
    'Sun-Mars': 'You energize each other\'s willpower',
    'Sun-Jupiter': 'They expand your sense of self',
    'Venus-Venus': 'Shared values and love language',
    'Venus-Mars': 'Magnetic attraction with ease',
    'Venus-Jupiter': 'Joy and abundance in connection',
    'Venus-Saturn': 'Love with lasting commitment',
    'Mars-Mars': 'Drives and ambitions align',
    'Mars-Jupiter': 'You inspire each other to act big',
    'Mars-Pluto': 'Powerful shared drive',
    'Jupiter-Jupiter': 'Shared vision and optimism',
    'Jupiter-Saturn': 'Balanced growth and structure',
    'Saturn-Saturn': 'Mutual respect for commitment',
  },
  'tense': {
    'Moon-Moon': 'Different emotional needs create growth',
    'Moon-Saturn': 'Emotions meet boundaries - security through structure',
    'Moon-Pluto': 'Emotional intensity that transforms you both',
    'Moon-Sun': 'Identity and emotions create friction that builds understanding',
    'Moon-Mars': 'Emotions spark reactions - learn to pause',
    'Sun-Sun': 'Strong personalities that must learn to share the stage',
    'Sun-Saturn': 'They challenge you to prove yourself',
    'Sun-Pluto': 'Intense power dynamics to navigate',
    'Sun-Mars': 'Will against will - respect through challenge',
    'Venus-Venus': 'Different values create dialogue',
    'Venus-Mars': 'Desire and love in dynamic tension',
    'Venus-Saturn': 'Love tested by reality',
    'Venus-Pluto': 'Intense attraction with power undertones',
    'Mars-Mars': 'Competing drives - channel into shared goals',
    'Mars-Saturn': 'Action meets limitation - builds discipline',
    'Mars-Pluto': 'Power struggles that forge strength',
    'Jupiter-Saturn': 'Expansion vs. contraction - find balance',
    'Saturn-Saturn': 'Different structures must find compromise',
  },
  'intense': {
    'Moon-Moon': 'Emotions sync completely',
    'Moon-Venus': 'Love and nurturing become one',
    'Moon-Pluto': 'Soul-deep emotional bond',
    'Moon-Sun': 'They feel like home to your soul',
    'Sun-Sun': 'Identities merge - you see yourself in them',
    'Sun-Venus': 'You adore who they are at their core',
    'Sun-Mars': 'Fused willpower - unstoppable together',
    'Sun-Pluto': 'Transformative impact on your identity',
    'Venus-Venus': 'Perfect harmony in love and values',
    'Venus-Mars': 'Desire and love unified',
    'Venus-Pluto': 'All-consuming attraction',
    'Mars-Mars': 'Drives amplified together',
    'Mars-Pluto': 'Unstoppable combined force',
    'Jupiter-Jupiter': 'Shared faith magnified',
    'Saturn-Saturn': 'Karmic commitment',
    'Neptune-Neptune': 'Spiritual connection',
    'Pluto-Pluto': 'Generational soul bond',
  },
};

// =============================================================================
// CONNECTION INSIGHTS
// =============================================================================

/// One-line insights by element combination.
const Map<String, List<String>> elementInsights = {
  'Water-Water': [
    'You feel each other\'s unspoken depths',
    'Emotional currents flow between you',
    'Intuition speaks louder than words',
    'You swim in the same emotional waters',
  ],
  'Fire-Fire': [
    'You ignite each other\'s passion',
    'Two flames burning brighter together',
    'Enthusiasm is contagious between you',
    'You dare each other to shine',
  ],
  'Earth-Earth': [
    'A foundation built on mutual trust',
    'You ground each other naturally',
    'Practical magic between you',
    'Steady presence, lasting connection',
  ],
  'Air-Air': [
    'Endless conversations await',
    'Ideas spark and multiply between you',
    'Mental connection runs electric',
    'You speak the same unspoken language',
  ],
  'Fire-Air': [
    'They fan your flames higher',
    'Ideas become action together',
    'Inspiration flows both ways',
    'You make each other bolder',
  ],
  'Air-Fire': [
    'They fan your flames higher',
    'Ideas become action together',
    'Inspiration flows both ways',
    'You make each other bolder',
  ],
  'Earth-Water': [
    'Emotions find safe harbor',
    'Nurturing meets steadiness',
    'You help each other bloom',
    'Depth meets dependability',
  ],
  'Water-Earth': [
    'Emotions find safe harbor',
    'Nurturing meets steadiness',
    'You help each other bloom',
    'Depth meets dependability',
  ],
  'Fire-Earth': [
    'Vision meets manifestation',
    'You balance dreams and reality',
    'Ambition finds its anchor',
    'Different speeds, same destination',
  ],
  'Earth-Fire': [
    'Vision meets manifestation',
    'You balance dreams and reality',
    'Ambition finds its anchor',
    'Different speeds, same destination',
  ],
  'Air-Water': [
    'Head and heart find balance',
    'Logic softened by feeling',
    'You translate each other\'s language',
    'Thinking meets intuition',
  ],
  'Water-Air': [
    'Head and heart find balance',
    'Logic softened by feeling',
    'You translate each other\'s language',
    'Thinking meets intuition',
  ],
  'Fire-Water': [
    'Steam rises when you meet',
    'Intensity creates transformation',
    'Passion meets emotional depth',
    'You challenge each other to grow',
  ],
  'Water-Fire': [
    'Steam rises when you meet',
    'Intensity creates transformation',
    'Passion meets emotional depth',
    'You challenge each other to grow',
  ],
  'Earth-Air': [
    'Ideas take form together',
    'Abstract meets practical',
    'You bridge thinking and doing',
    'Concepts become reality',
  ],
  'Air-Earth': [
    'Ideas take form together',
    'Abstract meets practical',
    'You bridge thinking and doing',
    'Concepts become reality',
  ],
};

/// Insights by tight aspect (orb < 3).
const Map<String, List<String>> aspectInsights = {
  'Moon-Sun': [
    'They feel like coming home',
    'Soul recognition at first sight',
    'Your lights complement perfectly',
  ],
  'Sun-Moon': [
    'They feel like coming home',
    'Soul recognition at first sight',
    'Your lights complement perfectly',
  ],
  'Moon-Moon': [
    'Emotional twins in different bodies',
    'You feel what they feel',
    'Hearts beating in sync',
  ],
  'Venus-Mars': [
    'Magnetic pull you can\'t ignore',
    'Chemistry written in the stars',
    'Attraction with depth',
  ],
  'Mars-Venus': [
    'Magnetic pull you can\'t ignore',
    'Chemistry written in the stars',
    'Attraction with depth',
  ],
  'Moon-Pluto': [
    'You transform each other\'s depths',
    'Emotional intensity as a gift',
    'Healing through connection',
  ],
  'Pluto-Moon': [
    'You transform each other\'s depths',
    'Emotional intensity as a gift',
    'Healing through connection',
  ],
  'Sun-Venus': [
    'They adore who you really are',
    'Seen and appreciated fully',
    'Love lights you up',
  ],
  'Venus-Sun': [
    'They adore who you really are',
    'Seen and appreciated fully',
    'Love lights you up',
  ],
};

// =============================================================================
// FREQUENCY DESCRIPTIONS
// =============================================================================

/// Descriptions for shared frequencies by quality.
const Map<String, List<String>> frequencyDescriptions = {
  'harmonious': [
    'Flowing Resonance',
    'Harmonic Blend',
    'Sympathetic Vibration',
    'Aligned Frequency',
    'Consonant Wave',
  ],
  'tense': [
    'Dynamic Tension',
    'Transformative Pulse',
    'Catalytic Frequency',
    'Friction Wave',
    'Growth Edge',
  ],
  'intense': [
    'Fused Frequency',
    'Unified Resonance',
    'Merged Vibration',
    'Power Tone',
    'Amplified Wave',
  ],
};

// =============================================================================
// MUSIC RECOMMENDATIONS
// =============================================================================

/// Song recommendation structure.
class SharedVibe {
  final String title;
  final String artist;
  final String mood;
  final String? spotifyId;
  
  const SharedVibe({
    required this.title,
    required this.artist,
    required this.mood,
    this.spotifyId,
  });
}

/// Music recommendations by element combination.
const Map<String, List<SharedVibe>> sharedVibesMapping = {
  'Water-Water': [
    SharedVibe(title: 'Dissolve', artist: 'Caribou', mood: 'Dreamy'),
    SharedVibe(title: 'Innerbloom', artist: 'RÜFÜS DU SOL', mood: 'Deep'),
    SharedVibe(title: 'Holocene', artist: 'Bon Iver', mood: 'Emotional'),
  ],
  'Fire-Fire': [
    SharedVibe(title: 'Midnight City', artist: 'M83', mood: 'Anthemic'),
    SharedVibe(title: 'The Less I Know The Better', artist: 'Tame Impala', mood: 'Bold'),
    SharedVibe(title: 'Take Me Out', artist: 'Franz Ferdinand', mood: 'Energetic'),
  ],
  'Earth-Earth': [
    SharedVibe(title: 'Harvest Moon', artist: 'Neil Young', mood: 'Warm'),
    SharedVibe(title: 'The Girl From Ipanema', artist: 'Stan Getz', mood: 'Steady'),
    SharedVibe(title: 'River', artist: 'Leon Bridges', mood: 'Soulful'),
  ],
  'Air-Air': [
    SharedVibe(title: 'Digital Love', artist: 'Daft Punk', mood: 'Playful'),
    SharedVibe(title: 'Electric Feel', artist: 'MGMT', mood: 'Eclectic'),
    SharedVibe(title: 'Genesis', artist: 'Grimes', mood: 'Stimulating'),
  ],
  'Fire-Air': [
    SharedVibe(title: 'Tessellate', artist: 'Alt-J', mood: 'Dynamic'),
    SharedVibe(title: 'Kids', artist: 'MGMT', mood: 'Uplifting'),
    SharedVibe(title: 'Rather Be', artist: 'Clean Bandit', mood: 'Exciting'),
  ],
  'Air-Fire': [
    SharedVibe(title: 'Tessellate', artist: 'Alt-J', mood: 'Dynamic'),
    SharedVibe(title: 'Kids', artist: 'MGMT', mood: 'Uplifting'),
    SharedVibe(title: 'Rather Be', artist: 'Clean Bandit', mood: 'Exciting'),
  ],
  'Earth-Water': [
    SharedVibe(title: 'Green Eyes', artist: 'Coldplay', mood: 'Comforting'),
    SharedVibe(title: 'Flowers', artist: 'Nao', mood: 'Nurturing'),
    SharedVibe(title: 'Cherry Wine', artist: 'Hozier', mood: 'Rich'),
  ],
  'Water-Earth': [
    SharedVibe(title: 'Green Eyes', artist: 'Coldplay', mood: 'Comforting'),
    SharedVibe(title: 'Flowers', artist: 'Nao', mood: 'Nurturing'),
    SharedVibe(title: 'Cherry Wine', artist: 'Hozier', mood: 'Rich'),
  ],
  'Fire-Water': [
    SharedVibe(title: 'Pyramid Song', artist: 'Radiohead', mood: 'Transformative'),
    SharedVibe(title: 'Teardrop', artist: 'Massive Attack', mood: 'Intense'),
    SharedVibe(title: 'Running Up That Hill', artist: 'Kate Bush', mood: 'Dramatic'),
  ],
  'Water-Fire': [
    SharedVibe(title: 'Pyramid Song', artist: 'Radiohead', mood: 'Transformative'),
    SharedVibe(title: 'Teardrop', artist: 'Massive Attack', mood: 'Intense'),
    SharedVibe(title: 'Running Up That Hill', artist: 'Kate Bush', mood: 'Dramatic'),
  ],
  'Fire-Earth': [
    SharedVibe(title: 'Seven Nation Army', artist: 'The White Stripes', mood: 'Powerful'),
    SharedVibe(title: 'Uprising', artist: 'Muse', mood: 'Triumphant'),
    SharedVibe(title: 'Black Skinhead', artist: 'Kanye West', mood: 'Determined'),
  ],
  'Earth-Fire': [
    SharedVibe(title: 'Seven Nation Army', artist: 'The White Stripes', mood: 'Powerful'),
    SharedVibe(title: 'Uprising', artist: 'Muse', mood: 'Triumphant'),
    SharedVibe(title: 'Black Skinhead', artist: 'Kanye West', mood: 'Determined'),
  ],
  'Air-Water': [
    SharedVibe(title: 'Glory Box', artist: 'Portishead', mood: 'Mysterious'),
    SharedVibe(title: 'Only Shallow', artist: 'My Bloody Valentine', mood: 'Ethereal'),
    SharedVibe(title: 'Breathe Me', artist: 'Sia', mood: 'Thoughtful'),
  ],
  'Water-Air': [
    SharedVibe(title: 'Glory Box', artist: 'Portishead', mood: 'Mysterious'),
    SharedVibe(title: 'Only Shallow', artist: 'My Bloody Valentine', mood: 'Ethereal'),
    SharedVibe(title: 'Breathe Me', artist: 'Sia', mood: 'Thoughtful'),
  ],
  'Earth-Air': [
    SharedVibe(title: 'Starlight', artist: 'Muse', mood: 'Crafted'),
    SharedVibe(title: 'Time', artist: 'Pink Floyd', mood: 'Progressive'),
    SharedVibe(title: 'Around The World', artist: 'Daft Punk', mood: 'Inventive'),
  ],
  'Air-Earth': [
    SharedVibe(title: 'Starlight', artist: 'Muse', mood: 'Crafted'),
    SharedVibe(title: 'Time', artist: 'Pink Floyd', mood: 'Progressive'),
    SharedVibe(title: 'Around The World', artist: 'Daft Punk', mood: 'Inventive'),
  ],
};

/// Default songs when no element match found.
const List<SharedVibe> defaultVibes = [
  SharedVibe(title: 'Midnight City', artist: 'M83', mood: 'Nostalgic'),
  SharedVibe(title: 'Dissolve', artist: 'Caribou', mood: 'Dreamy'),
  SharedVibe(title: 'Innerbloom', artist: 'RÜFÜS DU SOL', mood: 'Deep'),
];

// =============================================================================
// COSMIC GENRE MAPPING
// =============================================================================

/// Cosmic genre mapping based on element combinations.
/// Combines element energies to suggest musical genres.
class CosmicGenre {
  final String genre;
  final String subGenre;
  final String description;
  
  const CosmicGenre({
    required this.genre,
    required this.subGenre,
    required this.description,
  });
  
  String get displayText => '$genre / $subGenre';
}

const Map<String, CosmicGenre> cosmicGenreMapping = {
  // Same elements - amplified energy
  'Water-Water': CosmicGenre(genre: 'Ambient', subGenre: 'Downtempo', description: 'Oceanic depths'),
  'Fire-Fire': CosmicGenre(genre: 'Electronic', subGenre: 'Dance', description: 'High energy ignition'),
  'Earth-Earth': CosmicGenre(genre: 'Acoustic', subGenre: 'Folk', description: 'Grounded roots'),
  'Air-Air': CosmicGenre(genre: 'Indie', subGenre: 'Alternative', description: 'Free-flowing ideas'),
  
  // Compatible elements - harmonious blend
  'Fire-Air': CosmicGenre(genre: 'Synth-Pop', subGenre: 'New Wave', description: 'Electric inspiration'),
  'Air-Fire': CosmicGenre(genre: 'Synth-Pop', subGenre: 'New Wave', description: 'Electric inspiration'),
  'Earth-Water': CosmicGenre(genre: 'Neo-Soul', subGenre: 'R&B', description: 'Nurturing warmth'),
  'Water-Earth': CosmicGenre(genre: 'Neo-Soul', subGenre: 'R&B', description: 'Nurturing warmth'),
  
  // Neutral elements - creative tension
  'Fire-Earth': CosmicGenre(genre: 'Rock', subGenre: 'Blues Rock', description: 'Foundational fire'),
  'Earth-Fire': CosmicGenre(genre: 'Rock', subGenre: 'Blues Rock', description: 'Foundational fire'),
  'Air-Water': CosmicGenre(genre: 'Dream Pop', subGenre: 'Shoegaze', description: 'Ethereal currents'),
  'Water-Air': CosmicGenre(genre: 'Dream Pop', subGenre: 'Shoegaze', description: 'Ethereal currents'),
  
  // Challenging elements - transformative fusion
  'Fire-Water': CosmicGenre(genre: 'Trip-Hop', subGenre: 'Experimental', description: 'Steam rising'),
  'Water-Fire': CosmicGenre(genre: 'Trip-Hop', subGenre: 'Experimental', description: 'Steam rising'),
  'Earth-Air': CosmicGenre(genre: 'Art Rock', subGenre: 'Progressive', description: 'Abstract forms'),
  'Air-Earth': CosmicGenre(genre: 'Art Rock', subGenre: 'Progressive', description: 'Abstract forms'),
};

const CosmicGenre defaultGenre = CosmicGenre(
  genre: 'Electronic',
  subGenre: 'Ambient',
  description: 'Cosmic blend',
);

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Get element for a zodiac sign.
String? getElementForSign(String sign) {
  for (final entry in elements.entries) {
    if (entry.value.signs.contains(sign)) {
      return entry.key;
    }
  }
  return null;
}

/// Get sign colors.
Color getSignColor1(String sign) {
  final colors = signColors[sign];
  return colors != null ? Color(colors['color1']!) : const Color(0xFFFF59D0);
}

Color getSignColor2(String sign) {
  final colors = signColors[sign];
  return colors != null ? Color(colors['color2']!) : const Color(0xFF7D67FE);
}

/// Get quality color.
Color getQualityColor(String quality) {
  return Color(qualityColors[quality] ?? 0xFF00D4AA);
}
