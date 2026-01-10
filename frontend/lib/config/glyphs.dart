/// Glyph constants for consistent iconography across the app.
/// 
/// These Unicode glyphs replace emoji icons for a refined, cohesive aesthetic
/// that matches the planet symbols used throughout the app.
class AppGlyphs {
  AppGlyphs._();

  // Life Area Glyphs (for Sound RX, filters, etc.)
  static const String career = '△';       // Career & Purpose
  static const String love = '◇';         // Partnerships & Love
  static const String creativity = '✧';   // Creativity & Joy
  static const String health = '◎';       // Health & Vitality
  static const String communication = '◈'; // Communication & Expression
  static const String transformation = '⬡'; // Transformation & Growth
  static const String home = '⌂';         // Home & Family
  static const String wealth = '◆';       // Resources & Wealth
  static const String travel = '↗';       // Travel & Expansion
  static const String spirituality = '✦';  // Spirituality & Intuition

  // Status Glyphs
  static const String gap = '○';          // Attunement gap
  static const String resonance = '●';    // Resonance/strength
  static const String active = '◉';       // Active/playing
  static const String neutral = '◌';      // Neutral state

  // Cosmic Glyphs
  static const String moon = '☽';         // Moon phase
  static const String sun = '☉';          // Sun
  static const String star = '★';         // Star/highlight
  static const String starOutline = '☆';  // Star outline

  // Navigation/Action Glyphs
  static const String expand = '▾';       // Expand down
  static const String collapse = '▴';     // Collapse up
  static const String next = '›';         // Next/forward
  static const String play = '▶';         // Play
  static const String pause = '❚❚';       // Pause

  /// Get life area glyph by key
  static String forLifeArea(String key) {
    switch (key) {
      case 'career_purpose':
        return career;
      case 'partnerships':
        return love;
      case 'creativity_joy':
        return creativity;
      case 'health_service':
        return health;
      case 'communication':
        return communication;
      case 'transformation':
        return transformation;
      case 'home_family':
        return home;
      case 'resources':
        return wealth;
      case 'travel_expansion':
        return travel;
      case 'spirituality':
        return spirituality;
      default:
        return star;
    }
  }
}
