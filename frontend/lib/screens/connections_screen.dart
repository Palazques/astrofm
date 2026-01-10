import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../config/design_tokens.dart';
import 'main_shell.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/add_friend_sheet.dart';
import '../widgets/connections/constellation_map.dart';
import '../widgets/connections/friend_detail_card.dart';
import '../widgets/connections/background_stars.dart';
import '../widgets/connections/connections_empty_state.dart';
import '../models/friend_data.dart';
import '../models/sonification.dart';
import '../models/friend_harmony.dart';
import '../services/compatibility_service.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../data/test_users.dart';
import '../widgets/connections/friend_harmony_card.dart';

/// Connections (Friends) screen.
class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  String _filter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _compatibilityService = CompatibilityService();
  final _apiService = ApiService();
  final _audioService = AudioService();
  final _storageService = StorageService();

  // Constellation selection state
  FriendData? _selectedFriend;
  FriendData? _hoveredFriend;
  
  // Alignment state
  Map<int, AlignmentResponse> _alignmentResults = {};
  int? _aligningFriendId;
  bool _isPlayingBlend = false;
  StreamSubscription<bool>? _playingSubscription;
  
  // Friend suggestions state ("Listen to Your Friends Blend")
  FriendSuggestionsResponse? _friendSuggestions;
  bool _isLoadingSuggestions = false;

  // Friends data as FriendData objects
  late List<FriendData> _friends;
  late List<Map<String, dynamic>> _pendingRequests;

  @override
  void initState() {
    super.initState();
    _friends = [
      FriendData(
        id: 1, name: 'Maya Chen', username: '@mayachen',
        avatarColors: [AppColors.hotPink.value, AppColors.cosmicPurple.value],
        sunSign: 'Pisces', moonSign: 'Cancer', risingSign: 'Scorpio',
        dominantFrequency: '432 Hz', element: 'Water', modality: 'Mutable',
        compatibilityScore: 91, status: 'online', lastAligned: '2 hours ago',
        mutualPlanets: ['Moon', 'Venus'],
      ),
      FriendData(
        id: 2, name: 'Jordan Rivera', username: '@jordanrivera',
        avatarColors: [AppColors.electricYellow.value, AppColors.hotPink.value],
        sunSign: 'Aries', moonSign: 'Leo', risingSign: 'Sagittarius',
        dominantFrequency: '528 Hz', element: 'Fire', modality: 'Cardinal',
        compatibilityScore: 78, status: 'online', lastAligned: 'Yesterday',
        mutualPlanets: ['Mars', 'Sun'],
      ),
      FriendData(
        id: 3, name: 'Alex Kim', username: '@alexkim',
        avatarColors: [AppColors.cosmicPurple.value, AppColors.teal.value],
        sunSign: 'Scorpio', moonSign: 'Pisces', risingSign: 'Cancer',
        dominantFrequency: '396 Hz', element: 'Water', modality: 'Fixed',
        compatibilityScore: 87, status: 'offline', lastAligned: '3 days ago',
        mutualPlanets: ['Pluto', 'Moon'],
      ),
      FriendData(
        id: 4, name: 'Sam Taylor', username: '@samtaylor',
        avatarColors: [AppColors.teal.value, AppColors.electricYellow.value],
        sunSign: 'Leo', moonSign: 'Aries', risingSign: 'Leo',
        dominantFrequency: '639 Hz', element: 'Fire', modality: 'Fixed',
        compatibilityScore: 65, status: 'offline', lastAligned: '1 week ago',
        mutualPlanets: ['Sun'],
      ),
      FriendData(
        id: 5, name: 'Riley Morgan', username: '@rileymorgan',
        avatarColors: [AppColors.orange.value, AppColors.hotPink.value],
        sunSign: 'Libra', moonSign: 'Gemini', risingSign: 'Aquarius',
        dominantFrequency: '741 Hz', element: 'Air', modality: 'Cardinal',
        compatibilityScore: 82, status: 'online', lastAligned: '4 days ago',
        mutualPlanets: ['Venus', 'Mercury'],
      ),
      FriendData(
        id: 6, name: 'Casey Jones', username: '@caseyjones',
        avatarColors: [0xFFE84855, AppColors.cosmicPurple.value],
        sunSign: 'Virgo', moonSign: 'Capricorn', risingSign: 'Taurus',
        dominantFrequency: '852 Hz', element: 'Earth', modality: 'Mutable',
        compatibilityScore: 73, status: 'offline', lastAligned: '5 days ago',
        mutualPlanets: ['Mercury'],
      ),
      FriendData(
        id: 7, name: 'Drew Park', username: '@drewpark',
        avatarColors: [0xFF00B4D8, AppColors.electricYellow.value],
        sunSign: 'Aquarius', moonSign: 'Libra', risingSign: 'Gemini',
        dominantFrequency: '963 Hz', element: 'Air', modality: 'Fixed',
        compatibilityScore: 88, status: 'online', lastAligned: '1 day ago',
        mutualPlanets: ['Uranus', 'Moon'],
      ),
    ];
    
    _pendingRequests = [
      {'id': 101, 'name': 'Chris Lee', 'sign': 'Capricorn', 'color1': AppColors.cosmicPurple, 'color2': AppColors.electricYellow},
    ];
    
    // Fetch friend suggestions
    _loadFriendSuggestions();
  }
  
  Future<void> _loadFriendSuggestions() async {
    if (_friends.isEmpty) return;
    
    setState(() => _isLoadingSuggestions = true);
    
    try {
      final suggestions = await _apiService.getFriendSuggestions(
        friends: _friends,
        userId: 'default',
      );
      
      if (mounted) {
        setState(() {
          _friendSuggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      print('[FriendSuggestions] Error: $e');
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Stop audio when navigating away from the friends tab
    final controller = MainShellController.of(context);
    if (controller != null && controller.activeTab != 'friends') {
      // User navigated away from friends tab - stop any playing audio
      if (_isPlayingBlend) {
        _stopBlend();
      }
    }
  }

  @override
  void dispose() {
    _stopBlend();
    _playingSubscription?.cancel();
    _playingSubscription = null;
    _searchController.dispose();
    super.dispose();
  }

  Color _getCompatibilityColor(int score) {
    if (score >= 85) return AppColors.teal;
    if (score >= 70) return AppColors.electricYellow;
    if (score >= 50) return AppColors.orange;
    return AppColors.red;
  }

  List<FriendData> get filteredFriends {
    var list = List<FriendData>.from(_friends);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      list = list.where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    // Apply sort filter
    if (_filter == 'compatible') {
      list.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
    } else if (_filter == 'recent') {
      // Sort by lastAligned - simplified for mock data
      final order = ['2 hours ago', 'Yesterday', '1 day ago', '3 days ago', '4 days ago', '5 days ago', '1 week ago'];
      list.sort((a, b) => order.indexOf(a.lastAligned ?? '').compareTo(order.indexOf(b.lastAligned ?? '')));
    }
    
    return list;
  }

  List<FriendData> _getConnectedFriends(FriendData friend) {
    final connections = _compatibilityService.buildConnections(_friends);
    return _compatibilityService.getConnectedFriends(friend, connections);
  }

  void _showAddFriendSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => const AddFriendSheet(),
      ),
    );
  }

  void _acceptRequest(Map<String, dynamic> request) {
    setState(() {
      _pendingRequests.removeWhere((r) => r['id'] == request['id']);
      // Add to friends list as FriendData
      _friends.insert(0, FriendData(
        id: request['id'] as int,
        name: request['name'] as String,
        username: '@${(request['name'] as String).toLowerCase().replaceAll(' ', '')}',
        avatarColors: [(request['color1'] as Color).value, (request['color2'] as Color).value],
        sunSign: request['sign'] as String,
        moonSign: 'Unknown',
        risingSign: 'Unknown',
        dominantFrequency: '432 Hz',
        element: 'Unknown',
        modality: 'Unknown',
        compatibilityScore: 75, // Would be calculated by API
        status: 'online',
        lastAligned: 'Just now',
        mutualPlanets: ['Moon'],
      ));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${request['name']} added to your cosmic circle!',
                style: GoogleFonts.spaceGrotesk(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.backgroundMid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _declineRequest(Map<String, dynamic> request) {
    setState(() {
      _pendingRequests.removeWhere((r) => r['id'] == request['id']);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.white.withAlpha(179), size: 20),
            const SizedBox(width: 12),
            Text(
              'Request declined',
              style: GoogleFonts.spaceGrotesk(color: Colors.white.withAlpha(179)),
            ),
          ],
        ),
        backgroundColor: AppColors.backgroundMid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }



  void _navigateToFriendProfileFromData(FriendData friend) {
    Navigator.pushNamed(context, '/friend-profile', arguments: friend);
  }

  void _inviteFriends() {
    Share.share(
      '✨ Join me on Astro.FM! ✨\n\n'
      'Discover your cosmic sound, align with friends, and vibe to AI-curated playlists based on your birth chart.\n\n'
      '🌟 Download now and find your frequency: https://astro.fm/invite\n\n'
      '#AstroFM #CosmicVibes',
    );
  }

  /// Run alignment calculation for a friend
  Future<void> _runFriendAlignment(FriendData friend) async {
    // Stop any currently playing blend
    _stopBlend();
    
    setState(() => _aligningFriendId = friend.id);
    
    try {
      // Get user birth data from storage
      final userBirthData = await _storageService.loadBirthData();
      final userDatetime = userBirthData?.datetime ?? defaultTestBirthData['datetime'] as String;
      final userLatitude = userBirthData?.latitude ?? defaultTestBirthData['latitude'] as double;
      final userLongitude = userBirthData?.longitude ?? defaultTestBirthData['longitude'] as double;
      final userTimezone = userBirthData?.timezone ?? defaultTestBirthData['timezone'] as String;
      
      // Call Sound Signature alignment API for friend
      final alignmentResult = await _apiService.getFriendSoundSignatureAlignment(
        userDatetime: userDatetime,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        userTimezone: userTimezone,
        friendDatetime: friend.birthDatetime ?? '1992-03-21T14:30:00',
        friendLatitude: friend.birthLatitude ?? 40.7128,
        friendLongitude: friend.birthLongitude ?? -74.0060,
        friendName: friend.name.split(' ')[0],
      );
      
      if (mounted) {
        setState(() {
          _alignmentResults[friend.id] = alignmentResult;
          _aligningFriendId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _aligningFriendId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alignment failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
  
  /// Play the alignment blend audio
  void _playBlend() {
    if (_selectedFriend == null) return;
    
    final alignmentResult = _alignmentResults[_selectedFriend!.id];
    if (alignmentResult == null) return;
    
    if (_isPlayingBlend) {
      _stopBlend();
      return;
    }
    
    _audioService.playAlignmentSound(alignmentResult.sound);
    setState(() => _isPlayingBlend = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎵 Playing alignment meditation (${(alignmentResult.sound.suggestedDuration / 60).toStringAsFixed(0)} min)'),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    // Cancel any existing subscription before creating a new one
    _playingSubscription?.cancel();
    
    // Listen for playback completion
    _playingSubscription = _audioService.playingStream.listen((isPlaying) {
      if (!isPlaying && mounted && _isPlayingBlend) {
        setState(() => _isPlayingBlend = false);
      }
    });
  }
  
  /// Stop playing the blend audio
  void _stopBlend() {
    _playingSubscription?.cancel();
    _playingSubscription = null;
    if (_isPlayingBlend) {
      _audioService.stop();
      if (mounted) {
        setState(() => _isPlayingBlend = false);
      } else {
        _isPlayingBlend = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friends = filteredFriends;
    
    return Stack(
      children: [
        // Background stars
        const Positioned.fill(child: BackgroundStars()),
        const Positioned.fill(child: NebulaOverlay()),
        
        // Main content
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(
                  showBackButton: false,
                  showMenuButton: false,
                  title: 'Connections',
                  rightAction: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.cosmicPurple, AppColors.hotPink]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                      onPressed: _showAddFriendSheet,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                _buildSearchBar(),
                const SizedBox(height: 20),

                // Filter Buttons
                _buildFilterButtons(),
                const SizedBox(height: 20),

                // Pending Requests (compact)
                if (_pendingRequests.isNotEmpty) ...[
                  _buildPendingRequests(),
                  const SizedBox(height: 20),
                ],

                // Constellation Map or Empty State
                if (friends.isEmpty) ...[
                  ConnectionsEmptyState(onAddFriend: _showAddFriendSheet),
                ] else ...[
                  // Friend Harmony Card ("Listen to Your Friends Blend")
                  if (_isLoadingSuggestions || (_friendSuggestions != null && _friendSuggestions!.suggestions.isNotEmpty)) ...[
                    FriendHarmonyCard(
                      suggestion: _friendSuggestions?.suggestions.first ?? FriendHarmonySuggestion(
                        friendId: 0,
                        score: 0,
                        glowColor: '#7D67FE',
                        contextString: 'Loading...',
                        harmonyType: 'lunar',
                      ),
                      friend: _friendSuggestions != null && _friendSuggestions!.suggestions.isNotEmpty
                          ? _friends.firstWhere(
                              (f) => f.id == _friendSuggestions!.suggestions.first.friendId,
                              orElse: () => _friends.first,
                            )
                          : null,
                      currentMoonSign: _friendSuggestions?.currentMoonSign ?? 'Loading',
                      isLoading: _isLoadingSuggestions,
                      onTap: () {
                        if (_friendSuggestions != null && _friendSuggestions!.suggestions.isNotEmpty) {
                          final suggestedFriend = _friends.firstWhere(
                            (f) => f.id == _friendSuggestions!.suggestions.first.friendId,
                            orElse: () => _friends.first,
                          );
                          setState(() => _selectedFriend = suggestedFriend);
                        }
                      },
                      onAlignTap: () {
                        if (_friendSuggestions != null && _friendSuggestions!.suggestions.isNotEmpty) {
                          final suggestedFriend = _friends.firstWhere(
                            (f) => f.id == _friendSuggestions!.suggestions.first.friendId,
                            orElse: () => _friends.first,
                          );
                          setState(() => _selectedFriend = suggestedFriend);
                          _runFriendAlignment(suggestedFriend);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Constellation Map Section Header
                  Row(
                    children: [
                      Text('✦', style: TextStyle(color: AppColors.electricYellow, fontSize: 12)),
                      const SizedBox(width: 8),
                      Text(
                        'Your Constellation',
                        style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withAlpha(153)),
                      ),
                      Text(
                        ' · ${friends.length} stars',
                        style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(77)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Constellation Map
                  ConstellationMap(
                    friends: friends,
                    selectedFriend: _selectedFriend,
                    hoveredFriend: _hoveredFriend,
                    onFriendSelected: (friend) => setState(() => _selectedFriend = friend),
                    onFriendHovered: (friend) => setState(() => _hoveredFriend = friend),
                  ),
                  const SizedBox(height: 16),

                  // Friend Detail Card (shown when a friend is selected)
                  if (_selectedFriend != null)
                    FriendDetailCard(
                      friend: _selectedFriend!,
                      connectedFriends: _getConnectedFriends(_selectedFriend!),
                      onProfileTap: () => _navigateToFriendProfileFromData(_selectedFriend!),
                      onAlignTap: () => _runFriendAlignment(_selectedFriend!),
                      onConnectedFriendTap: (friend) => setState(() => _selectedFriend = friend),
                      alignmentResult: _alignmentResults[_selectedFriend!.id],
                      isAligning: _aligningFriendId == _selectedFriend!.id,
                      isPlayingBlend: _isPlayingBlend,
                      onPlayBlendTap: _playBlend,
                    ),
                  
                  // Invite Friends CTA
                  const SizedBox(height: 24),
                  _buildInviteFriendsCta(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: Colors.white.withAlpha(102), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white),
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search connections...',
                hintStyle: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(102)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Icon(Icons.clear_rounded, color: Colors.white.withAlpha(102), size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        _FilterButton(label: 'All', isActive: _filter == 'all', onPressed: () => setState(() => _filter = 'all')),
        const SizedBox(width: 10),
        _FilterButton(label: 'Recent', isActive: _filter == 'recent', onPressed: () => setState(() => _filter = 'recent')),
        const SizedBox(width: 10),
        _FilterButton(label: 'Most Compatible', isActive: _filter == 'compatible', onPressed: () => setState(() => _filter = 'compatible')),
      ],
    );
  }

  Widget _buildPendingRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Pending Requests', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withAlpha(179))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.hotPink, borderRadius: BorderRadius.circular(10)),
              child: Text('${_pendingRequests.length}', style: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.background)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Compact single pending request card
        if (_pendingRequests.isNotEmpty)
          _buildPendingRequestCard(_pendingRequests.first),
      ],
    );
  }

  Widget _buildPendingRequestCard(Map<String, dynamic> request) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [request['color1'] as Color, request['color2'] as Color]),
            ),
            child: Center(child: Text((request['name'] as String)[0], style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request['name'] as String, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('wants to connect', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128))),
              ],
            ),
          ),
          Row(
            children: [
              _ActionButton(
                icon: Icons.close_rounded,
                color: Colors.white.withAlpha(26),
                onPressed: () => _declineRequest(request),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.check_rounded,
                color: AppColors.teal,
                onPressed: () => _acceptRequest(request),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInviteFriendsCta() {
    return GestureDetector(
      onTap: _inviteFriends,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cosmicPurple.withAlpha(51),
              AppColors.hotPink.withAlpha(38),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.hotPink.withAlpha(51)),
        ),
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
              child: const Icon(Icons.share_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Friends',
                    style: GoogleFonts.syne(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Share your cosmic link & grow your constellation',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: Colors.white.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white.withAlpha(102),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _FilterButton({required this.label, required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.electricYellow.withAlpha(38) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.electricYellow.withAlpha(77) : Colors.white.withAlpha(26)),
        ),
        child: Text(label, style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? AppColors.electricYellow : Colors.white.withAlpha(128))),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
