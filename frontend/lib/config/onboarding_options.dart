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

/// Complete genre list with 25 main genres and 7 subgenres each.
const List<GenreData> genreData = [
  GenreData('Pop', [
    'Dance Pop',
    'Synth-Pop',
    'Teen Pop',
    'Electropop',
    'Indie Pop',
    'Art Pop',
    'Pop Rock',
  ]),
  GenreData('Rock', [
    'Alternative Rock',
    'Classic Rock',
    'Hard Rock',
    'Indie Rock',
    'Punk Rock',
    'Progressive Rock',
    'Grunge',
  ]),
  GenreData('Country', [
    'Contemporary Country',
    'Country Pop',
    'Americana',
    'Outlaw Country',
    'Country Rock',
    'Bluegrass',
    'Alt-Country',
  ]),
  GenreData('Electronic', [
    'EDM',
    'House',
    'Techno',
    'Trance',
    'Dubstep',
    'Drum & Bass',
    'Ambient',
  ]),
  GenreData('Hip Hop / R&B', [
    'Trap',
    'Boom Bap',
    'Alternative Hip Hop',
    'Conscious Hip Hop',
    'Neo-Soul',
    'Contemporary R&B',
    'Drill',
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
  GenreData('Jazz', [
    'Bebop',
    'Swing',
    'Cool Jazz',
    'Fusion',
    'Smooth Jazz',
    'Hard Bop',
    'Free Jazz',
  ]),
  GenreData('Classical', [
    'Baroque',
    'Classical Period',
    'Romantic',
    'Contemporary Classical',
    'Minimalism',
    'Chamber Music',
    'Opera',
  ]),
  GenreData('Latin', [
    'Reggaeton',
    'Latin Pop',
    'Salsa',
    'Bachata',
    'Regional Mexican',
    'Latin Trap',
    'Merengue',
  ]),
  GenreData('Folk', [
    'Traditional Folk',
    'Contemporary Folk',
    'Folk Rock',
    'Americana',
    'Celtic Folk',
    'Singer-Songwriter',
    'Acoustic Folk',
  ]),
  GenreData('World', [
    'African Traditional',
    'Middle Eastern',
    'Indian Classical',
    'Balkan',
    'Andean',
    'Caribbean Traditional',
    'Southeast Asian',
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
  GenreData('Metal', [
    'Heavy Metal',
    'Thrash Metal',
    'Death Metal',
    'Black Metal',
    'Metalcore',
    'Progressive Metal',
    'Doom Metal',
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
  GenreData('Blues', [
    'Delta Blues',
    'Chicago Blues',
    'Texas Blues',
    'Electric Blues',
    'Blues Rock',
    'Country Blues',
    'Contemporary Blues',
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
  GenreData('Punk', [
    'Hardcore Punk',
    'Pop Punk',
    'Post-Punk',
    'Punk Rock',
    'Anarcho-Punk',
    'Skate Punk',
    'Garage Punk',
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
  GenreData('Disco', [
    'Classic Disco',
    'Euro Disco',
    'Italo Disco',
    'Nu-Disco',
    'Disco Funk',
    'Dance Disco',
    'Post-Disco',
  ]),
  GenreData('Gospel', [
    'Traditional Gospel',
    'Contemporary Gospel',
    'Urban Gospel',
    'Southern Gospel',
    'Praise & Worship',
    'Gospel Soul',
    'Gospel Pop',
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
  GenreData('Ambient', [
    'Dark Ambient',
    'Space Ambient',
    'Drone',
    'Ambient Electronic',
    'Nature Ambient',
    'Meditation',
    'Experimental Ambient',
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
