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

/// Complete genre list with 24 main genres and 7 subgenres each.
/// Restructured per Music Library Integration Plan.
const List<GenreData> genreData = [
  // Pop/Contemporary (4)
  GenreData('Pop', [
    'Dance Pop',
    'Synth-Pop',
    'K-Pop',
    'J-Pop',
    'Electropop',
    'Indie Pop',
    'Art Pop',
  ]),
  GenreData('K-Pop', [
    'Idol Pop',
    'K-Rap',
    'K-R&B',
    'Dance K-Pop',
    'Experimental K-Pop',
    'Ballad K-Pop',
    'Electronic K-Pop',
  ]),
  GenreData('J-Pop', [
    'Idol Pop',
    'J-Rock',
    'City Pop',
    'Anime Soundtrack',
    'J-Electronic',
    'J-R&B',
    'J-Folk',
  ]),
  GenreData('Disco', [
    'Classic Disco',
    'Euro Disco',
    'Italo Disco',
    'Nu-Disco',
    'Disco Funk',
    'Dance Disco',
    'Post-Disco',
  ]),

  // Rock & Adjacent (4)
  GenreData('Rock', [
    'Alternative Rock',
    'Classic Rock',
    'Hard Rock',
    'Indie Rock',
    'Punk Rock',
    'Grunge',
    'Progressive Rock',
  ]),
  GenreData('Indie', [
    'Indie Rock',
    'Indie Pop',
    'Indie Folk',
    'Indie Electronic',
    'Dream Pop',
    'Lo-Fi',
    'Shoegaze',
  ]),
  GenreData('Metal', [
    'Heavy Metal',
    'Thrash Metal',
    'Death Metal',
    'Black Metal',
    'Metalcore',
    'Progressive Metal',
    'Doom Metal',
  ]),
  GenreData('Punk', [
    'Hardcore Punk',
    'Pop Punk',
    'Post-Punk',
    'Punk Rock',
    'Anarcho-Punk',
    'Skate Punk',
    'Garage Punk',
  ]),

  // Electronic (1 - includes Trance, House, Techno as subgenres)
  GenreData('Electronic', [
    'EDM',
    'House',
    'Techno',
    'Trance',
    'Dubstep',
    'Drum & Bass',
    'Ambient',
  ]),

  // Hip Hop & Soul (3)
  GenreData('Hip Hop / R&B', [
    'Trap',
    'Boom Bap',
    'Alternative Hip Hop',
    'Neo-Soul',
    'Contemporary R&B',
    'Drill',
    'Conscious Hip Hop',
  ]),
  GenreData('Soul', [
    'Classic Soul',
    'Neo-Soul',
    'Motown',
    'Southern Soul',
    'Psychedelic Soul',
    'Funk Soul',
    'Contemporary Soul',
  ]),
  GenreData('Funk', [
    'Classic Funk',
    'P-Funk',
    'Funk Rock',
    'Electro-Funk',
    'Soul Funk',
    'Jazz Funk',
    'Funk Pop',
  ]),

  // Classical & Jazz (2)
  GenreData('Classical', [
    'Baroque',
    'Classical Period',
    'Romantic',
    'Contemporary Classical',
    'Minimalism',
    'Chamber Music',
    'Opera',
  ]),
  GenreData('Jazz', [
    'Bebop',
    'Swing',
    'Cool Jazz',
    'Fusion',
    'Smooth Jazz',
    'Hard Bop',
    'Free Jazz',
  ]),

  // Acoustic & Folk (2) - Folk replaces Acoustic, Country updated
  GenreData('Folk', [
    'Traditional Folk',
    'Contemporary Folk',
    'Folk Rock',
    'Americana',
    'Celtic Folk',
    'Singer-Songwriter',
    'Acoustic Folk',
  ]),
  GenreData('Country', [
    'Contemporary Country',
    'Country Pop',
    'Americana',
    'Outlaw Country',
    'Bluegrass',
    'Alt-Country',
    'Country Rock',
  ]),

  // World Music & Latin (4) - Latin and Reggae are new
  GenreData('Latin', [
    'Reggaeton',
    'Latin Pop',
    'Salsa',
    'Bachata',
    'Regional Mexican',
    'Latin Trap',
    'Merengue',
  ]),
  GenreData('World Music', [
    'World Music',
  ]),
  GenreData('Reggae', [
    'Roots Reggae',
    'Dancehall',
    'Dub',
    'Lovers Rock',
    'Ska',
    'Rocksteady',
    'Reggae Fusion',
  ]),
  GenreData('Afrobeats', [
    'Afropop',
    'Afro-Fusion',
    'Afro-House',
    'Alté',
    'Afro-Trap',
    'Azonto',
    'Highlife',
  ]),

  // Blues (1)
  GenreData('Blues', [
    'Delta Blues',
    'Chicago Blues',
    'Texas Blues',
    'Electric Blues',
    'Blues Rock',
    'Country Blues',
    'Contemporary Blues',
  ]),

  // Spiritual & Soundtrack (3) - Religious is new
  GenreData('New Age', [
    'Dark Ambient',
    'Space Ambient',
    'Drone',
    'Ambient Electronic',
    'Nature Ambient',
    'Meditation',
    'Experimental Ambient',
  ]),
  GenreData('Religious', [
    'Gospel',
    'Contemporary Christian',
    'Traditional Gospel',
    'Urban Gospel',
    'Southern Gospel',
    'Praise & Worship',
    'Gospel Soul',
  ]),
  GenreData('Soundtrack', [
    'Film Score',
    'Television Score',
    'Video Game Music',
    'Orchestral Score',
    'Ambient Score',
    'Cinematic',
    'Trailer Music',
  ]),
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
