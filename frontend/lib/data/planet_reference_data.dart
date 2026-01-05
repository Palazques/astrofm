import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Static reference data for planet sound details.
/// Based on astrology_vibe_logic.md and spec documentation.

// ============================================================================
// PLANET CORE DATA
// ============================================================================

/// Planet archetypes describing their essential nature.
const Map<String, String> planetArchetypes = {
  'Sun': 'The Life Force',
  'Moon': 'The Nurturer',
  'Mercury': 'The Messenger',
  'Venus': 'The Lover',
  'Mars': 'The Warrior',
  'Jupiter': 'The Expander',
  'Saturn': 'The Teacher',
  'Uranus': 'The Awakener',
  'Neptune': 'The Dreamer',
  'Pluto': 'The Transformer',
  'North Node': 'The Destiny Point',
  'Chiron': 'The Wounded Healer',
};

/// Planet keywords for quick reference tags.
const Map<String, List<String>> planetKeywords = {
  'Sun': ['Identity', 'Vitality', 'Purpose', 'Expression'],
  'Moon': ['Emotions', 'Intuition', 'Nurturing', 'Security'],
  'Mercury': ['Communication', 'Thinking', 'Learning', 'Perception'],
  'Venus': ['Love', 'Beauty', 'Values', 'Pleasure'],
  'Mars': ['Action', 'Drive', 'Courage', 'Desire'],
  'Jupiter': ['Growth', 'Wisdom', 'Abundance', 'Faith'],
  'Saturn': ['Structure', 'Discipline', 'Mastery', 'Time'],
  'Uranus': ['Innovation', 'Freedom', 'Rebellion', 'Awakening'],
  'Neptune': ['Dreams', 'Spirituality', 'Illusion', 'Transcendence'],
  'Pluto': ['Rebirth', 'Shadow work', 'Hidden power', 'Regeneration'],
  'North Node': ['Life path', 'Growth edge', 'Destiny', 'Soul purpose'],
  'Chiron': ['Healing', 'Wounds', 'Teaching', 'Integration'],
};

/// Planet waveform types as sonic textures.
const Map<String, String> planetWaveforms = {
  'Sun': 'Carrier/Foundation Tone',
  'Moon': 'Rhythmic/Fluid Modulator',
  'Mercury': 'High-Frequency Detail Tone',
  'Venus': 'Harmonic Resonance Tone',
  'Mars': 'Pulsing/Percussive Tone',
  'Jupiter': 'Harmonic Layer Tone',
  'Saturn': 'Low-Frequency Grounding Drone',
  'Uranus': 'Glitch/Unpredictable Filter Tone',
  'Neptune': 'Reverb/Echo Ambient Tone',
  'Pluto': 'Sub-Bass/Intense Filter Tone',
  'North Node': 'Ascending Harmonic Tone',
  'Chiron': 'Healing Frequency Modulator',
};

/// Poetic sound descriptions for each planet.
const Map<String, String> planetSoundDescriptions = {
  'Sun':
      'A warm, golden hum at the center of your being. This is the sound of your core self—steady, radiant, and life-giving. It anchors everything else.',
  'Moon':
      'A gentle, flowing rhythm that ebbs and swells like tides. This sound holds your emotional memory, shifting with your inner weather.',
  'Mercury':
      'Quick, bright patterns that dart and weave through the mix. This is the sound of your mind in motion—curious, adaptive, always connecting.',
  'Venus':
      'Lush, harmonious tones that invite you to linger. This is the sound of what you love and how you love—magnetic, beautiful, pleasurable.',
  'Mars':
      'A driving pulse that pushes forward with intention. This is the sound of your will in action—bold, direct, unstoppable when focused.',
  'Jupiter':
      'An expansive, optimistic swell that lifts everything higher. This is the sound of your faith and growth—generous, wise, ever-reaching.',
  'Saturn':
      'A deep, steady drone that provides structure to the chaos. This is the sound of your mastery—patient, disciplined, hard-won.',
  'Uranus':
      'Unexpected frequencies that break through the pattern. This is the sound of your genius—electric, revolutionary, authentically strange.',
  'Neptune':
      'Vast, oceanic reverb that dissolves all boundaries. This is the sound of your spirit—dreamy, transcendent, infinitely deep.',
  'Pluto':
      'A deep, almost imperceptible vibration that rises from silence. This is the sound of things ending and beginning again—slow, inevitable, powerful.',
  'North Node':
      'A calling tone that pulls you forward into growth. This is the sound of your becoming—unfamiliar yet magnetic, your soul\'s direction.',
  'Chiron':
      'A bittersweet frequency that transforms pain into wisdom. This is the sound of your deepest wound becoming your greatest gift.',
};

// ============================================================================
// HOUSE DATA
// ============================================================================

/// House themes - one-liner for each house domain.
const Map<int, String> houseThemes = {
  1: 'Self & Identity',
  2: 'Values & Resources',
  3: 'Communication & Mind',
  4: 'Home & Roots',
  5: 'Creativity & Joy',
  6: 'Service & Health',
  7: 'Partnership',
  8: 'Transformation & Intimacy',
  9: 'Expansion & Philosophy',
  10: 'Career & Legacy',
  11: 'Community & Visions',
  12: 'The Unconscious',
};

/// House meaning templates for each house.
const Map<int, String> _houseMeaningTemplates = {
  1: 'Your {planet} energy is immediately visible. {planetName} in the 1st house means {keyword} is core to how you present yourself to the world.',
  2: 'Your {planet} energy manifests through what you value and own. {planetName} here shapes your relationship with money, possessions, and self-worth.',
  3: 'Your {planet} energy flows through communication and thought. {planetName} in the 3rd colors how you learn, speak, and connect with your immediate environment.',
  4: 'Your {planet} energy roots itself in home and family. {planetName} in the 4th shapes your private life, emotional foundation, and sense of belonging.',
  5: 'Your {planet} energy expresses through creativity and joy. {planetName} in the 5th influences romance, children, play, and artistic expression.',
  6: 'Your {planet} energy is channeled through service and routine. {planetName} in the 6th affects your daily habits, work style, and approach to health.',
  7: 'Your {planet} energy activates in partnership. {planetName} in the 7th shapes how you relate one-on-one, what you seek in others, and how you balance give and take.',
  8: 'Your {planet} energy plunges into the depths. {planetName} in the 8th deals with shared resources, intimacy, death/rebirth cycles, and psychological transformation.',
  9: 'Your {planet} energy seeks expansion and meaning. {planetName} in the 9th influences your philosophy, higher learning, travel, and search for truth.',
  10: 'Your {planet} energy aims toward achievement and legacy. {planetName} in the 10th shapes your career, public image, and what you\'re building in the world.',
  11: 'Your {planet} energy connects with the collective. {planetName} in the 11th influences your friendships, groups, causes, and vision for the future.',
  12: 'Your {planet} energy works through the unseen realms. {planetName} in the 12th operates through dreams, solitude, the unconscious, and spiritual connection.',
};

/// Planet-in-house keywords for specific combinations.
const Map<int, Map<String, String>> _houseKeywords = {
  1: {
    'Sun': 'identity and self-expression',
    'Moon': 'emotional responsiveness',
    'Mercury': 'intellectual curiosity',
    'Venus': 'charm and aesthetic sense',
    'Mars': 'assertiveness and initiative',
    'Jupiter': 'optimism and presence',
    'Saturn': 'seriousness and authority',
    'Uranus': 'uniqueness and unpredictability',
    'Neptune': 'dreaminess and sensitivity',
    'Pluto': 'intensity and magnetism',
    'North Node': 'self-discovery',
    'Chiron': 'vulnerability',
  },
  2: {
    'Sun': 'finding identity through resources',
    'Moon': 'emotional security through stability',
    'Mercury': 'thinking about finances and values',
    'Venus': 'attracting abundance naturally',
    'Mars': 'actively pursuing material goals',
    'Jupiter': 'natural abundance and generosity',
    'Saturn': 'building lasting financial security',
    'Uranus': 'unconventional values and income',
    'Neptune': 'idealistic or unclear finances',
    'Pluto': 'transformative relationship with power and money',
    'North Node': 'developing self-worth',
    'Chiron': 'healing around value and worth',
  },
  3: {
    'Sun': 'shining through words and ideas',
    'Moon': 'thinking with feeling',
    'Mercury': 'natural mental agility',
    'Venus': 'graceful communication',
    'Mars': 'direct and assertive speech',
    'Jupiter': 'expansive thinking and learning',
    'Saturn': 'structured, careful communication',
    'Uranus': 'revolutionary ideas',
    'Neptune': 'poetic and imaginative thought',
    'Pluto': 'penetrating mental power',
    'North Node': 'developing communication skills',
    'Chiron': 'healing through words and learning',
  },
  4: {
    'Sun': 'finding identity through family',
    'Moon': 'deep emotional attunement to home',
    'Mercury': 'family communication patterns',
    'Venus': 'creating beauty in the home',
    'Mars': 'active or competitive home life',
    'Jupiter': 'generous, expansive home environment',
    'Saturn': 'responsibility for family',
    'Uranus': 'unconventional family dynamics',
    'Neptune': 'idealized or unclear family patterns',
    'Pluto': 'transformative family experiences',
    'North Node': 'building emotional security',
    'Chiron': 'healing family wounds',
  },
  5: {
    'Sun': 'natural creative radiance',
    'Moon': 'emotional investment in creativity',
    'Mercury': 'playful intellect',
    'Venus': 'artistic talent and romantic charm',
    'Mars': 'passionate creative drive',
    'Jupiter': 'abundant creative joy',
    'Saturn': 'disciplined creativity',
    'Uranus': 'avant-garde expression',
    'Neptune': 'imaginative artistry',
    'Pluto': 'intense creative power',
    'North Node': 'embracing creative joy',
    'Chiron': 'healing through creative expression',
  },
  6: {
    'Sun': 'identity through work and service',
    'Moon': 'emotional connection to daily routines',
    'Mercury': 'analytical work approach',
    'Venus': 'pleasant work environment needs',
    'Mars': 'energetic work ethic',
    'Jupiter': 'finding meaning in service',
    'Saturn': 'disciplined work habits',
    'Uranus': 'unconventional work methods',
    'Neptune': 'service-oriented idealism',
    'Pluto': 'transforming through work',
    'North Node': 'developing service orientation',
    'Chiron': 'healing through helping others',
  },
  7: {
    'Sun': 'identity through partnership',
    'Moon': 'emotional needs in relationship',
    'Mercury': 'mental connection in partnership',
    'Venus': 'natural relationship harmony',
    'Mars': 'passion and conflict in partnership',
    'Jupiter': 'growth through partnership',
    'Saturn': 'commitment and responsibility in love',
    'Uranus': 'freedom needs in relationship',
    'Neptune': 'idealistic partnership views',
    'Pluto': 'transformative partnerships',
    'North Node': 'learning through relationship',
    'Chiron': 'healing through partnership',
  },
  8: {
    'Sun': 'identity through transformation',
    'Moon': 'emotional intensity and depth',
    'Mercury': 'probing, investigative mind',
    'Venus': 'deep intimacy needs',
    'Mars': 'intense desire nature',
    'Jupiter': 'growth through crisis',
    'Saturn': 'mastery over fear',
    'Uranus': 'sudden transformations',
    'Neptune': 'spiritual transformation',
    'Pluto': 'profound regenerative power',
    'North Node': 'embracing transformation',
    'Chiron': 'healing through facing shadows',
  },
  9: {
    'Sun': 'identity through beliefs and exploration',
    'Moon': 'emotional need for meaning',
    'Mercury': 'philosophical thinking',
    'Venus': 'love of culture and travel',
    'Mars': 'crusading for beliefs',
    'Jupiter': 'natural philosophical wisdom',
    'Saturn': 'structured belief systems',
    'Uranus': 'unconventional philosophies',
    'Neptune': 'spiritual seeking',
    'Pluto': 'transforming through truth',
    'North Node': 'expanding worldview',
    'Chiron': 'healing through wisdom',
  },
  10: {
    'Sun': 'public identity and recognition',
    'Moon': 'emotional investment in career',
    'Mercury': 'communication-based career',
    'Venus': 'career in beauty or diplomacy',
    'Mars': 'ambitious career drive',
    'Jupiter': 'successful public expansion',
    'Saturn': 'hard-won professional mastery',
    'Uranus': 'unconventional career path',
    'Neptune': 'idealistic career visions',
    'Pluto': 'powerful public presence',
    'North Node': 'fulfilling public destiny',
    'Chiron': 'healing through achievement',
  },
  11: {
    'Sun': 'identity through community',
    'Moon': 'emotional bonds with friends',
    'Mercury': 'networking and group communication',
    'Venus': 'social grace and group harmony',
    'Mars': 'active in group causes',
    'Jupiter': 'influential in social circles',
    'Saturn': 'responsible group roles',
    'Uranus': 'revolutionary social visions',
    'Neptune': 'idealistic social dreams',
    'Pluto': 'transforming through groups',
    'North Node': 'finding your tribe',
    'Chiron': 'healing through community',
  },
  12: {
    'Sun': 'hidden identity, spiritual self',
    'Moon': 'deep unconscious emotions',
    'Mercury': 'intuitive, non-linear thinking',
    'Venus': 'secret loves, hidden beauty',
    'Mars': 'unconscious drives, hidden anger',
    'Jupiter': 'spiritual faith and protection',
    'Saturn': 'karmic responsibilities',
    'Uranus': 'unconscious genius',
    'Neptune': 'natural spiritual attunement',
    'Pluto': 'transforming through surrender',
    'North Node': 'spiritual development',
    'Chiron': 'healing the collective wound',
  },
};

/// Get the meaning of a planet in a specific house.
String getPlanetInHouseMeaning(String planetName, int house) {
  final template = _houseMeaningTemplates[house] ?? '';
  final keyword = _houseKeywords[house]?[planetName] ?? 'unique expression';

  return template
      .replaceAll('{planet}', planetName)
      .replaceAll('{planetName}', planetName)
      .replaceAll('{keyword}', keyword);
}

// ============================================================================
// ASPECT DATA
// ============================================================================

/// Aspect type display properties.
class AspectDisplayData {
  final String symbol;
  final String quality;
  final Color color;
  final String description;

  const AspectDisplayData({
    required this.symbol,
    required this.quality,
    required this.color,
    required this.description,
  });
}

/// Display data for each aspect type.
const Map<String, AspectDisplayData> aspectDisplayData = {
  'Conjunction': AspectDisplayData(
    symbol: '☌',
    quality: 'intense',
    color: Color(0xFFFAFF0E),
    description: 'merges with',
  ),
  'Conjunct': AspectDisplayData(
    symbol: '☌',
    quality: 'intense',
    color: Color(0xFFFAFF0E),
    description: 'merges with',
  ),
  'Sextile': AspectDisplayData(
    symbol: '⚹',
    quality: 'harmonious',
    color: Color(0xFF00D4AA),
    description: 'supports',
  ),
  'Square': AspectDisplayData(
    symbol: '□',
    quality: 'tense',
    color: Color(0xFFE84855),
    description: 'challenges',
  ),
  'Trine': AspectDisplayData(
    symbol: '△',
    quality: 'harmonious',
    color: Color(0xFF00D4AA),
    description: 'flows with',
  ),
  'Opposition': AspectDisplayData(
    symbol: '☍',
    quality: 'tense',
    color: Color(0xFFE84855),
    description: 'opposes',
  ),
};

/// Aspect meanings organized by quality.
const Map<String, Map<String, String>> _aspectMeanings = {
  'harmonious': {
    'Sun-Moon':
        'Your conscious identity and emotional nature work together naturally. What you want and what you need align.',
    'Sun-Mercury':
        'Your mind serves your identity well. Self-expression through communication comes easily.',
    'Sun-Venus':
        'Your identity radiates charm and creativity. Love and self-expression are intertwined.',
    'Sun-Mars':
        'Your will and drive work as one. Action expresses your authentic self.',
    'Sun-Jupiter':
        'Your identity expands with optimism. Growth and self-expression support each other.',
    'Sun-Saturn':
        'Your identity has structure and discipline. Responsibility serves your purpose.',
    'Sun-Uranus':
        'Your authentic self embraces uniqueness. Innovation expresses your identity.',
    'Sun-Neptune':
        'Your identity connects with the spiritual. Creativity flows from transcendence.',
    'Sun-Pluto':
        'Your identity has depth and power. Transformation serves your evolution.',
    'Moon-Mercury':
        'Your feelings and thoughts work together. Emotional intelligence comes naturally.',
    'Moon-Venus':
        'Your emotional nature and love style harmonize. Nurturing and beauty intertwine.',
    'Moon-Mars': 'Your feelings fuel your actions. Emotional drive is balanced.',
    'Moon-Jupiter':
        'Your emotions are buoyant and generous. Nurturing comes with optimism.',
    'Moon-Saturn':
        'Your emotions have structure. Security comes through emotional discipline.',
    'Moon-Uranus':
        'Your emotional nature embraces change. Freedom and security coexist.',
    'Moon-Neptune':
        'Your emotions connect to the infinite. Intuition and feeling merge.',
    'Moon-Pluto':
        'Your emotional depths flow easily with transformation. Healing comes naturally.',
    'Mercury-Venus':
        'Your mind and heart communicate well. Thinking about love comes easily.',
    'Mercury-Mars':
        'Your thoughts and actions align. Mental assertiveness is balanced.',
    'Mercury-Jupiter':
        'Your thinking expands easily. Learning and philosophy blend well.',
    'Mercury-Saturn':
        'Your mind has structure. Disciplined thinking comes naturally.',
    'Mercury-Uranus':
        'Your mind is innovatively wired. Original thoughts flow easily.',
    'Mercury-Neptune':
        'Your thinking is imaginative. Intuition and logic work together.',
    'Mercury-Pluto': 'Your mind probes deeply. Insight comes naturally.',
    'Venus-Mars':
        'Your love and desire natures harmonize. Attraction and action blend.',
    'Venus-Jupiter':
        'Your love nature is generous. Beauty and abundance flow together.',
    'Venus-Saturn': 'Your love is committed. Beauty has structure.',
    'Venus-Uranus': 'Your love embraces freedom. Attraction to the unique.',
    'Venus-Neptune': 'Your love is spiritual. Romance and imagination merge.',
    'Venus-Pluto': 'Your love is profound. Attraction has transformative depth.',
    'Mars-Jupiter': 'Your drive is expansive. Action and growth align.',
    'Mars-Saturn': 'Your drive is disciplined. Action has structure.',
    'Mars-Uranus': 'Your drive is innovative. Action breaks patterns.',
    'Mars-Neptune': 'Your drive is inspired. Action serves vision.',
    'Mars-Pluto': 'Your drive is powerful. Action transforms.',
    'Jupiter-Saturn': 'Your expansion is grounded. Growth has structure.',
    'Jupiter-Uranus': 'Your growth is revolutionary. Expansion breaks limits.',
    'Jupiter-Neptune': 'Your faith is transcendent. Growth is spiritual.',
    'Jupiter-Pluto': 'Your growth is profound. Expansion transforms.',
    'Saturn-Uranus': 'Your structure adapts. Discipline serves innovation.',
    'Saturn-Neptune': 'Your structure holds spirit. Discipline serves dreams.',
    'Saturn-Pluto': 'Your structure transforms. Discipline has depth.',
    'Uranus-Neptune':
        'Your awakening is spiritual. Innovation serves transcendence.',
    'Uranus-Pluto': 'Your awakening transforms. Innovation has depth.',
    'Neptune-Pluto': 'Your dreams transform. Spirit and depth merge.',
  },
  'tense': {
    'Sun-Moon':
        'Your wants and needs create tension. Conscious goals and emotional security must find balance.',
    'Sun-Mercury':
        'Your identity and mind can clash. Self-expression and communication need integration.',
    'Sun-Venus':
        'Your identity and love nature tension. Self-expression and relationship needs require balance.',
    'Sun-Mars':
        'Your will and drive create friction. Identity and action must find harmony.',
    'Sun-Jupiter': 'Your identity and expansion clash. Ego and growth need balance.',
    'Sun-Saturn':
        'Your identity meets limitation. Self-expression and responsibility create tension.',
    'Sun-Uranus':
        'Your identity and freedom clash. Stability and change create tension.',
    'Sun-Neptune':
        'Your identity and spirit create confusion. Reality and dreams need integration.',
    'Sun-Pluto': 'Your identity faces transformation. Ego and power create tension.',
    'Moon-Mercury':
        'Your feelings and thoughts clash. Emotion and logic need balance.',
    'Moon-Venus':
        'Your emotional needs and love style create tension. Nurturing and pleasure need integration.',
    'Moon-Mars':
        'Your feelings and actions clash. Emotional reactions need channeling.',
    'Moon-Jupiter':
        'Your emotions and expansion create excess. Security and growth need balance.',
    'Moon-Saturn':
        'Your emotions meet limitation. Security and discipline create tension.',
    'Moon-Uranus':
        'Your emotions and freedom clash. Security and change create tension.',
    'Moon-Neptune':
        'Your emotions can be confused. Security and transcendence need grounding.',
    'Moon-Pluto':
        'Your emotions face intensity. Security and transformation create tension.',
    'Mercury-Venus':
        'Your mind and heart have different agendas. Logic and values need balance.',
    'Mercury-Mars':
        'Your thoughts and actions clash. Mind and drive need integration.',
    'Mercury-Jupiter':
        'Your mind can overexpand. Details and big picture need balance.',
    'Mercury-Saturn':
        'Your mind meets blocks. Thinking and limitation create friction.',
    'Mercury-Uranus':
        'Your mind can scatter. Stability and innovation need balance.',
    'Mercury-Neptune':
        'Your thinking can be unclear. Logic and imagination need grounding.',
    'Mercury-Pluto':
        'Your mind can obsess. Thinking and intensity need balance.',
    'Venus-Mars':
        'Your love and desire clash. Attraction and action create tension.',
    'Venus-Jupiter':
        'Your love and expansion create excess. Values and growth need limits.',
    'Venus-Saturn': 'Your love meets limitation. Pleasure and duty create tension.',
    'Venus-Uranus':
        'Your love and freedom clash. Stability and excitement need balance.',
    'Venus-Neptune':
        'Your love can be unrealistic. Romance and reality need integration.',
    'Venus-Pluto': 'Your love faces intensity. Attraction and power create tension.',
    'Mars-Jupiter':
        'Your drive can overextend. Action and expansion need limits.',
    'Mars-Saturn': 'Your drive meets blocks. Action and limitation create friction.',
    'Mars-Uranus':
        'Your drive can be erratic. Action and freedom need channeling.',
    'Mars-Neptune':
        'Your drive can be diffused. Action and dreams need grounding.',
    'Mars-Pluto':
        'Your drive faces power struggles. Action and intensity need integration.',
    'Jupiter-Saturn':
        'Your expansion meets limitation. Growth and structure create tension.',
    'Jupiter-Uranus':
        'Your growth can be disruptive. Expansion and change need direction.',
    'Jupiter-Neptune':
        'Your faith can be unrealistic. Growth and dreams need grounding.',
    'Jupiter-Pluto':
        'Your growth faces power dynamics. Expansion and transformation create intensity.',
    'Saturn-Uranus':
        'Your structure and freedom clash. Stability and change create tension.',
    'Saturn-Neptune':
        'Your structure and spirit clash. Reality and dreams create confusion.',
    'Saturn-Pluto':
        'Your structure faces transformation. Control and power create tension.',
    'Uranus-Neptune':
        'Your awakening and spirit can confuse. Innovation and transcendence need grounding.',
    'Uranus-Pluto':
        'Your awakening faces intensity. Revolution and transformation create upheaval.',
    'Neptune-Pluto':
        'Your dreams face transformation. Spirit and depth create intensity.',
  },
  'conjunction': {
    'Sun-Moon':
        'Your wants and needs are unified. Identity and emotion are inseparable—what you show is what you feel.',
    'Sun-Mercury':
        'Your mind and identity merge. You think as you are, speak as you think.',
    'Sun-Venus':
        'Your identity and love merge. You are what you love, charm is innate.',
    'Sun-Mars': 'Your identity and drive merge. Action and self are one.',
    'Sun-Jupiter':
        'Your identity and expansion merge. Confidence and growth are innate.',
    'Sun-Saturn': 'Your identity and structure merge. Responsibility defines you.',
    'Sun-Uranus': 'Your identity and uniqueness merge. You are the revolution.',
    'Sun-Neptune': 'Your identity and spirit merge. You are the dream.',
    'Sun-Pluto': 'Your identity and power merge. Transformation defines you.',
    'Moon-Mercury':
        'Your feelings and thoughts are one. Emotional thinking, thought-feeling.',
    'Moon-Venus': 'Your emotions and love merge. Feeling is loving.',
    'Moon-Mars': 'Your emotions and drive merge. Feelings fuel action directly.',
    'Moon-Jupiter': 'Your emotions and faith merge. Feelings are expansive.',
    'Moon-Saturn': 'Your emotions and structure merge. Feelings are controlled.',
    'Moon-Uranus': 'Your emotions and freedom merge. Feelings are electric.',
    'Moon-Neptune': 'Your emotions and spirit merge. Feelings are oceanic.',
    'Moon-Pluto': 'Your emotions and power merge. Feelings are intense.',
    'Mercury-Venus': 'Your mind and heart merge. Thinking is loving.',
    'Mercury-Mars': 'Your mind and drive merge. Thinking is action.',
    'Mercury-Jupiter': 'Your mind and expansion merge. Thinking is growth.',
    'Mercury-Saturn': 'Your mind and structure merge. Thinking is discipline.',
    'Mercury-Uranus': 'Your mind and innovation merge. Thinking is revolution.',
    'Mercury-Neptune': 'Your mind and spirit merge. Thinking is dreaming.',
    'Mercury-Pluto': 'Your mind and power merge. Thinking is probing.',
    'Venus-Mars': 'Your love and drive merge. Desire is action.',
    'Venus-Jupiter': 'Your love and expansion merge. Beauty is abundance.',
    'Venus-Saturn': 'Your love and structure merge. Commitment is love.',
    'Venus-Uranus': 'Your love and freedom merge. Attraction is electric.',
    'Venus-Neptune': 'Your love and spirit merge. Romance is transcendent.',
    'Venus-Pluto': 'Your love and power merge. Attraction is transformative.',
    'Mars-Jupiter': 'Your drive and expansion merge. Action is growth.',
    'Mars-Saturn': 'Your drive and structure merge. Action is discipline.',
    'Mars-Uranus': 'Your drive and innovation merge. Action is revolution.',
    'Mars-Neptune': 'Your drive and spirit merge. Action is inspired.',
    'Mars-Pluto': 'Your drive and power merge. Action is transformative.',
    'Jupiter-Saturn': 'Your expansion and structure merge. Growth is grounded.',
    'Jupiter-Uranus': 'Your expansion and innovation merge. Growth breaks limits.',
    'Jupiter-Neptune': 'Your expansion and spirit merge. Faith is transcendent.',
    'Jupiter-Pluto': 'Your expansion and power merge. Growth is profound.',
    'Saturn-Uranus': 'Your structure and freedom merge. Discipline innovates.',
    'Saturn-Neptune': 'Your structure and spirit merge. Form holds dream.',
    'Saturn-Pluto': 'Your structure and power merge. Authority transforms.',
    'Uranus-Neptune': 'Your awakening and spirit merge. Innovation transcends.',
    'Uranus-Pluto': 'Your awakening and power merge. Revolution transforms.',
    'Neptune-Pluto': 'Your dreams and power merge. Spirit transforms.',
  },
};

/// Get the meaning of an aspect between two planets.
String getAspectMeaning(String planet1, String planet2, String aspectType) {
  // Create key (alphabetical order for consistency)
  final planets = [planet1, planet2]..sort();
  final key = '${planets[0]}-${planets[1]}';

  // Determine quality based on aspect type
  final String quality;
  if (aspectType == 'Conjunction' || aspectType == 'Conjunct') {
    quality = 'conjunction';
  } else if (aspectType == 'Sextile' || aspectType == 'Trine') {
    quality = 'harmonious';
  } else {
    quality = 'tense';
  }

  return _aspectMeanings[quality]?[key] ??
      '$planet1 ${aspectType.toLowerCase()} $planet2 creates a $quality connection.';
}

// ============================================================================
// SOUND BLEND DESCRIPTIONS
// ============================================================================

/// Sound blend descriptions by quality.
const Map<String, Map<String, String>> _soundBlends = {
  'harmonious': {
    'Sun-Moon':
        'The Sun\'s golden foundation tone embraces the Moon\'s fluid rhythm, creating warmth that pulses with emotion.',
    'Sun-Mercury':
        'The Sun\'s radiance sharpens Mercury\'s quick patterns, thoughts crystallizing into clear expression.',
    'Sun-Venus':
        'The Sun\'s warmth enriches Venus\'s harmonics, creating a sound of magnetic radiance.',
    'Sun-Mars':
        'The Sun\'s steady glow accelerates with Mars\'s driving pulse—vitality in motion.',
    'Sun-Jupiter':
        'The Sun\'s foundation expands with Jupiter\'s optimistic swell—confidence amplified.',
    'Sun-Saturn':
        'The Sun\'s brightness is grounded by Saturn\'s steady drone—purpose with structure.',
    'Sun-Neptune':
        'The Sun\'s core dissolves into Neptune\'s reverb—identity becoming infinite.',
    'Sun-Pluto':
        'The Sun\'s vitality deepens with Pluto\'s sub-bass—radiance with hidden power.',
    'Moon-Venus':
        'The Moon\'s rhythm harmonizes with Venus\'s lush tones—emotional beauty.',
    'Moon-Jupiter':
        'The Moon\'s tides lift with Jupiter\'s expansion—feelings that fill the room.',
    'Moon-Saturn':
        'The Moon\'s flow steadies with Saturn\'s structure—emotions you can trust.',
    'Moon-Neptune':
        'The Moon\'s rhythm dissolves into Neptune\'s ocean—feeling without boundary.',
    'Moon-Pluto': 'The Moon\'s softness deepens with Pluto\'s intensity—emotional power.',
    'Venus-Mars': 'Venus\'s harmonics blend with Mars\'s pulse—beauty in motion.',
    'Venus-Jupiter':
        'Venus\'s sweetness expands with Jupiter\'s abundance—love overflowing.',
    'Venus-Neptune':
        'Venus\'s beauty dissolves into Neptune\'s mist—love becoming art.',
    'Mars-Jupiter': 'Mars\'s drive expands with Jupiter\'s faith—action with meaning.',
    'Jupiter-Saturn':
        'Jupiter\'s swell is grounded by Saturn\'s bass—growth you can build on.',
    'Saturn-Pluto':
        'Saturn\'s structure deepens with Pluto\'s power—authority that transforms.',
    'Neptune-Pluto':
        'Neptune\'s reverb meets Pluto\'s depths—spirit dissolving into transformation.',
  },
  'tense': {
    'Sun-Moon':
        'The Sun\'s steady tone pulls against the Moon\'s shifting rhythm—a productive friction between want and need.',
    'Sun-Saturn':
        'The Sun\'s brightness meets Saturn\'s weight—radiance earning its place through discipline.',
    'Sun-Pluto':
        'The Sun\'s identity meets Pluto\'s depths—ego confronting transformation.',
    'Moon-Mars':
        'The Moon\'s softness sparks against Mars\'s aggression—emotions fueling action, sometimes too fast.',
    'Moon-Saturn':
        'The Moon\'s flow meets Saturn\'s rigidity—feelings seeking safe structure.',
    'Moon-Pluto':
        'The Moon\'s vulnerability meets Pluto\'s intensity—emotional depth through transformation.',
    'Venus-Mars':
        'Venus\'s harmony clashes with Mars\'s pulse—desire creating tension with beauty.',
    'Venus-Saturn': 'Venus\'s pleasure meets Saturn\'s duty—love requiring commitment.',
    'Venus-Pluto': 'Venus\'s grace meets Pluto\'s intensity—attraction that transforms.',
    'Mars-Saturn': 'Mars\'s drive hits Saturn\'s wall—action requiring patience.',
    'Mars-Pluto': 'Mars\'s aggression meets Pluto\'s power—force meeting force.',
    'Jupiter-Saturn':
        'Jupiter\'s expansion meets Saturn\'s contraction—growth requiring discipline.',
    'Saturn-Uranus':
        'Saturn\'s structure meets Uranus\'s disruption—old forms breaking for new.',
    'Uranus-Pluto':
        'Uranus\'s revolution meets Pluto\'s transformation—change at the deepest level.',
  },
  'conjunction': {
    'Sun-Moon':
        'The Sun and Moon sound as one—a unified tone where identity and emotion are indistinguishable.',
    'Sun-Pluto':
        'The Sun\'s core merges with Pluto\'s depths—a sound of intense, transformative presence.',
    'Moon-Pluto':
        'The Moon\'s rhythm fuses with Pluto\'s intensity—emotions of profound depth.',
    'Venus-Mars': 'Venus and Mars merge into one pulse—desire and beauty inseparable.',
    'Mars-Pluto': 'Mars and Pluto combine—raw power made conscious.',
    'Saturn-Pluto': 'Saturn and Pluto merge—structure forged in transformation.',
    'Neptune-Pluto': 'Neptune and Pluto dissolve together—spirit meeting the void.',
  },
};

/// Get the sound blend description for two planets in aspect.
String getSoundBlend(
    String planet1, String planet2, String aspectType, String quality) {
  final planets = [planet1, planet2]..sort();
  final key = '${planets[0]}-${planets[1]}';

  final blendType = (aspectType == 'Conjunction' || aspectType == 'Conjunct')
      ? 'conjunction'
      : quality;

  return _soundBlends[blendType]?[key] ??
      '$planet1\'s frequency ${quality == 'harmonious' ? 'harmonizes' : 'creates tension'} with $planet2\'s tone.';
}

// ============================================================================
// INTENSITY CALCULATION
// ============================================================================

/// Calculate intensity based on degree position in house (bell curve).
/// Mid-house (15°) = 100% intensity, cusps (0° and 30°) = minimum.
int calculateIntensity(double degree) {
  final distanceFromMid = (degree - 15).abs();
  final intensity = math.cos((distanceFromMid / 15) * (math.pi / 2)) * 100;
  return intensity.round().clamp(0, 100);
}
