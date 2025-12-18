/// Predefined options for onboarding selection screens.

/// Options for "How did you find us?" screen.
const List<String> howFoundUsOptions = [
  'TikTok',
  'Instagram',
  'Friend Referral',
  'App Store Search',
  'Twitter/X',
  'YouTube',
  'Podcast',
  'Other',
];

/// Genre data structure with main genres and their subgenres.
class GenreData {
  final String name;
  final List<String> subgenres;

  const GenreData(this.name, this.subgenres);
}

/// Complete genre list with 15 main genres and 5 subgenres each.
const List<GenreData> genreData = [
  GenreData('Pop', ['Synth-Pop', 'Indie Pop', 'Dance Pop', 'Art Pop', 'Electropop']),
  GenreData('Hip-Hop', ['Lo-Fi Hip-Hop', 'Trap', 'Boom Bap', 'Cloud Rap', 'Conscious']),
  GenreData('R&B', ['Neo-Soul', 'Contemporary R&B', 'Alternative R&B', 'Quiet Storm', 'New Jack Swing']),
  GenreData('Electronic', ['House', 'Techno', 'Trance', 'Drum & Bass', 'Dubstep']),
  GenreData('Rock', ['Alternative', 'Indie Rock', 'Prog Rock', 'Psychedelic', 'Post-Rock']),
  GenreData('Indie', ['Dream Pop', 'Shoegaze', 'Bedroom Pop', 'Lo-Fi Indie', 'Art Rock']),
  GenreData('Jazz', ['Smooth Jazz', 'Nu-Jazz', 'Bebop', 'Jazz Fusion', 'Cool Jazz']),
  GenreData('Classical', ['Contemporary', 'Orchestral', 'Baroque', 'Minimalist', 'Film Score']),
  GenreData('Latin', ['Reggaeton', 'Latin Pop', 'Bachata', 'Salsa', 'Cumbia']),
  GenreData('Country', ['Americana', 'Country Pop', 'Outlaw', 'Bluegrass', 'Alt-Country']),
  GenreData('Folk', ['Acoustic', 'Singer-Songwriter', 'Indie Folk', 'Celtic', 'Appalachian']),
  GenreData('Metal', ['Progressive', 'Alt-Metal', 'Black Metal', 'Doom Metal', 'Metalcore']),
  GenreData('Ambient', ['Chillwave', 'Downtempo', 'Dark Ambient', 'Space Ambient', 'New Age']),
  GenreData('World', ['Afrobeat', 'Bossa Nova', 'Reggae', 'K-Pop', 'J-Pop']),
  GenreData('Soul', ['Funk', 'Motown', 'Northern Soul', 'Philly Soul', 'Gospel']),
];

/// Flat list of main genre names for backward compatibility.
List<String> get genreOptions => genreData.map((g) => g.name).toList();

/// Flat list of all subgenres.
List<String> get allSubgenres =>
    genreData.expand((g) => g.subgenres).toList();

/// Get subgenres for a specific main genre.
List<String> getSubgenresFor(String genre) {
  final data = genreData.where((g) => g.name == genre).firstOrNull;
  return data?.subgenres ?? [];
}

/// Premium pricing constants
class PremiumPricing {
  static const double monthlyPrice = 6.99;
  static const double sixMonthPrice = 33.55; // 20% off
  static const double annualPrice = 41.94; // 50% off
  
  static const double referralDiscountPercent = 50;
  static const int referralDiscountMonths = 3;
  static const int referralsRequired = 3;
  
  // Discounted prices (first 3 months with referral)
  static double get monthlyDiscounted => monthlyPrice * 0.5;
  static double get sixMonthDiscounted => sixMonthPrice * 0.5;
  static double get annualDiscounted => annualPrice - (monthlyPrice * 0.5 * 3); // Prorated 3 months
  
  // Monthly equivalents for display
  static double get monthlyPerMonth => monthlyPrice;
  static double get sixMonthPerMonth => sixMonthPrice / 6;
  static double get annualPerMonth => annualPrice / 12;
}
