import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/glass_card.dart';

/// Bottom sheet modal for searching and adding new friends.
class AddFriendSheet extends StatefulWidget {
  const AddFriendSheet({super.key});

  @override
  State<AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<AddFriendSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  final Set<int> _sentRequests = {};

  // Mock search results - in production would come from API
  final _mockUsers = [
    {'id': 201, 'name': 'Luna Starweaver', 'username': '@lunaweaver', 'sign': 'Aquarius', 'color1': AppColors.cosmicPurple, 'color2': AppColors.teal},
    {'id': 202, 'name': 'Orion Blake', 'username': '@orionblake', 'sign': 'Sagittarius', 'color1': AppColors.electricYellow, 'color2': AppColors.orange},
    {'id': 203, 'name': 'Nova Martinez', 'username': '@novamars', 'sign': 'Virgo', 'color1': AppColors.hotPink, 'color2': AppColors.cosmicPurple},
    {'id': 204, 'name': 'Stellar Ray', 'username': '@stellarray', 'sign': 'Capricorn', 'color1': AppColors.teal, 'color2': AppColors.electricYellow},
    {'id': 205, 'name': 'Celeste Moon', 'username': '@celestemoon', 'sign': 'Cancer', 'color1': AppColors.hotPink, 'color2': AppColors.teal},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });

    // Simulate API delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        if (query.isEmpty) {
          _searchResults = [];
        } else {
          _searchResults = _mockUsers.where((user) {
            final name = (user['name'] as String).toLowerCase();
            final username = (user['username'] as String).toLowerCase();
            return name.contains(query.toLowerCase()) ||
                   username.contains(query.toLowerCase());
          }).toList();
        }
      });
    });
  }

  void _sendFriendRequest(int userId) {
    setState(() {
      _sentRequests.add(userId);
    });
    
    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 20),
            const SizedBox(width: 12),
            Text(
              'Friend request sent!',
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.backgroundMid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.cosmicPurple, AppColors.hotPink],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a Friend',
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Search by name or username',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.white.withAlpha(128)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(26)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.spaceGrotesk(fontSize: 15, color: Colors.white),
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: 'Search for friends...',
                  hintStyle: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    color: Colors.white.withAlpha(77),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withAlpha(77),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.white.withAlpha(77),
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _search('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Results
          Flexible(
            child: _buildResults(),
          ),
          
          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cosmicPurple),
          ),
        ),
      );
    }

    if (_searchQuery.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_add_rounded,
              size: 48,
              color: Colors.white.withAlpha(51),
            ),
            const SizedBox(height: 16),
            Text(
              'Find your cosmic connections',
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(102),
              ),
            ),
            Text(
              'Search for friends by their name or username',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: Colors.white.withAlpha(77),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.white.withAlpha(51),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(102),
              ),
            ),
            Text(
              'Try a different search term',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: Colors.white.withAlpha(77),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final hasSentRequest = _sentRequests.contains(user['id']);
        
        return GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [user['color1'] as Color, user['color2'] as Color],
                  ),
                ),
                child: Center(
                  child: Text(
                    (user['name'] as String)[0],
                    style: GoogleFonts.syne(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] as String,
                      style: GoogleFonts.syne(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          user['username'] as String,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.white.withAlpha(102),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(13),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user['sign'] as String,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: Colors.white.withAlpha(77),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Add button
              if (hasSentRequest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.teal.withAlpha(51)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, color: AppColors.teal, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Sent',
                        style: GoogleFonts.syne(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _sendFriendRequest(user['id'] as int),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.cosmicPurple, AppColors.hotPink],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: GoogleFonts.syne(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
