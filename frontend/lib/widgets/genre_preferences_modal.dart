import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../config/onboarding_options.dart';
import '../services/storage_service.dart';

/// Modal for editing user's genre preferences.
/// Uses a simpler expandable list UI instead of the animated solar system.
class GenrePreferencesModal extends StatefulWidget {
  final List<String> initialGenres;
  final List<String> initialSubgenres;
  final VoidCallback? onSaved;

  const GenrePreferencesModal({
    super.key,
    required this.initialGenres,
    required this.initialSubgenres,
    this.onSaved,
  });

  /// Show the modal as a bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required List<String> initialGenres,
    required List<String> initialSubgenres,
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GenrePreferencesModal(
        initialGenres: initialGenres,
        initialSubgenres: initialSubgenres,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<GenrePreferencesModal> createState() => _GenrePreferencesModalState();
}

class _GenrePreferencesModalState extends State<GenrePreferencesModal> {
  late Set<String> _selectedGenres;
  late Set<String> _selectedSubgenres;
  String? _expandedGenre;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedGenres = Set.from(widget.initialGenres);
    _selectedSubgenres = Set.from(widget.initialSubgenres);
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
        // Also remove its subgenres
        final subgenres = getSubgenresFor(genre);
        _selectedSubgenres.removeAll(subgenres);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  void _toggleSubgenre(String subgenre, String parentGenre) {
    setState(() {
      if (_selectedSubgenres.contains(subgenre)) {
        _selectedSubgenres.remove(subgenre);
      } else {
        _selectedSubgenres.add(subgenre);
        // Ensure parent genre is selected
        _selectedGenres.add(parentGenre);
      }
    });
  }

  void _toggleExpanded(String genre) {
    setState(() {
      _expandedGenre = _expandedGenre == genre ? null : genre;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    
    await storageService.saveGenres(
      _selectedGenres.toList(),
      _selectedSubgenres.toList(),
    );
    
    if (mounted) {
      Navigator.pop(context);
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Genres',
                  style: GoogleFonts.syne(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          
          // Selection count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cosmicPurple.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedGenres.length} genres • ${_selectedSubgenres.length} subgenres',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppColors.cosmicPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Genre list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: genreData.length,
              itemBuilder: (context, index) {
                final genre = genreData[index];
                final isSelected = _selectedGenres.contains(genre.name);
                final isExpanded = _expandedGenre == genre.name;
                
                return _buildGenreItem(genre, isSelected, isExpanded);
              },
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark.withAlpha(200),
              border: Border(
                top: BorderSide(color: Colors.white.withAlpha(26)),
              ),
            ),
            child: Column(
              children: [
                // Info text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Colors.white.withAlpha(102),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Changes will apply to your next playlist',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white.withAlpha(102),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cosmicPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Preferences',
                            style: GoogleFonts.syne(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreItem(GenreData genre, bool isSelected, bool isExpanded) {
    // Count selected subgenres for this genre
    final selectedSubCount = genre.subgenres
        .where((s) => _selectedSubgenres.contains(s))
        .length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.cosmicPurple.withAlpha(26)
            : AppColors.glassBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.cosmicPurple.withAlpha(77)
              : AppColors.glassBorder,
        ),
      ),
      child: Column(
        children: [
          // Main genre row
          InkWell(
            onTap: () => _toggleExpanded(genre.name),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Expand/collapse icon
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: Colors.white.withAlpha(128),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  
                  // Genre name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          genre.name,
                          style: GoogleFonts.syne(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (selectedSubCount > 0)
                          Text(
                            '$selectedSubCount subgenres selected',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: AppColors.cosmicPurple,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Checkbox for main genre
                  GestureDetector(
                    onTap: () => _toggleGenre(genre.name),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.cosmicPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.cosmicPurple
                              : Colors.white.withAlpha(77),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Subgenres (when expanded)
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withAlpha(20)),
                ),
              ),
              child: Column(
                children: genre.subgenres.map((subgenre) {
                  final isSubSelected = _selectedSubgenres.contains(subgenre);
                  
                  return InkWell(
                    onTap: () => _toggleSubgenre(subgenre, genre.name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 32), // Indent
                          
                          // Subgenre checkbox
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSubSelected
                                  ? AppColors.hotPink
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: isSubSelected
                                    ? AppColors.hotPink
                                    : Colors.white.withAlpha(51),
                                width: 1.5,
                              ),
                            ),
                            child: isSubSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          
                          // Subgenre name
                          Text(
                            subgenre,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              color: isSubSelected
                                  ? Colors.white
                                  : Colors.white.withAlpha(179),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
