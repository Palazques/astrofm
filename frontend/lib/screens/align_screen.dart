import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/sound_orb.dart';
import '../services/api_service.dart';
import '../models/alignment.dart';

/// Align screen for frequency alignment.
class AlignScreen extends StatefulWidget {
  const AlignScreen({super.key});

  @override
  State<AlignScreen> createState() => _AlignScreenState();
}

class _AlignScreenState extends State<AlignScreen> {
  final ApiService _apiService = ApiService();
  
  String _alignTarget = 'today';
  bool _isAligning = false;
  double _alignmentProgress = 0;
  int _resonanceScore = 0;
  int? _selectedFriendId;
  String? _dominantEnergy;
  String? _alignmentDescription;

  // Test birth data - in production, this would come from user profile
  final _birthData = {
    'datetime': '1990-07-15T15:42:00',
    'latitude': 34.0522,
    'longitude': -118.2437,
    'timezone': 'America/Los_Angeles',
  };

  final friends = [
    {'id': 1, 'name': 'Maya', 'color1': AppColors.hotPink, 'color2': AppColors.cosmicPurple, 'compatibility': 87},
    {'id': 2, 'name': 'Jordan', 'color1': AppColors.electricYellow, 'color2': AppColors.hotPink, 'compatibility': 72},
    {'id': 3, 'name': 'Alex', 'color1': AppColors.cosmicPurple, 'color2': AppColors.teal, 'compatibility': 91},
    {'id': 4, 'name': 'Sam', 'color1': AppColors.teal, 'color2': AppColors.electricYellow, 'compatibility': 65},
  ];

  final upcomingTransits = [
    {'id': 1, 'name': 'Full Moon in Cancer', 'date': 'Dec 15', 'energy': 'Emotional Release'},
    {'id': 2, 'name': 'Mercury enters Capricorn', 'date': 'Dec 18', 'energy': 'Structured Thinking'},
  ];

  void _startAlignment() {
    setState(() {
      _isAligning = true;
      _alignmentProgress = 0;
      _resonanceScore = 0;
    });

    _runAlignment();
  }

  Future<void> _runAlignment() async {
    // Start cosmetic progress animation
    _animateProgress();
    
    try {
      if (_alignTarget == 'today') {
        // Make actual API call for daily alignment
        final result = await _apiService.getDailyAlignment(
          datetime: _birthData['datetime'] as String,
          latitude: _birthData['latitude'] as double,
          longitude: _birthData['longitude'] as double,
          timezone: _birthData['timezone'] as String,
        );
        
        if (mounted) {
          setState(() {
            _alignmentProgress = 1.0;
            _resonanceScore = result.score;
            _dominantEnergy = result.dominantEnergy;
            _alignmentDescription = result.description;
          });
        }
      } else if (_alignTarget == 'friend' && _selectedFriendId != null) {
        // For friend alignment, use mock data for now (requires friend API)
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          setState(() {
            _alignmentProgress = 1.0;
            _resonanceScore = friends.firstWhere((f) => f['id'] == _selectedFriendId)['compatibility'] as int;
            _dominantEnergy = 'Harmonious';
            _alignmentDescription = 'Your frequencies blend well together.';
          });
        }
      } else {
        // Transit alignment - use mock for now
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          setState(() {
            _alignmentProgress = 1.0;
            _resonanceScore = 75;
            _dominantEnergy = 'Dynamic';
            _alignmentDescription = 'Transformative energies approaching.';
          });
        }
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alignment failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade900,
          ),
        );
        setState(() {
          _alignmentProgress = 0;
          _resonanceScore = 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAligning = false);
      }
    }
  }

  Future<void> _animateProgress() async {
    // Cosmetic animation while API loads
    for (int i = 0; i <= 85; i += 3) {
      if (!_isAligning || !mounted) break;
      await Future.delayed(const Duration(milliseconds: 40));
      setState(() => _alignmentProgress = i / 100);
    }
  }

  void _resetAlignment() {
    setState(() {
      _alignmentProgress = 0;
      _resonanceScore = 0;
      _isAligning = false;
      _dominantEnergy = null;
      _alignmentDescription = null;
    });
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppHeader(
              showBackButton: true,
              showMenuButton: false,
              title: 'Align',
            ),
            const SizedBox(height: 16),

            // Alignment Visualization
            _buildAlignmentVisualization(),
            const SizedBox(height: 24),

            // Resonance Result
            if (_resonanceScore > 0) ...[
              _buildResonanceResult(),
              const SizedBox(height: 24),
            ],

            // Target Selection Tabs
            _buildTargetTabs(),
            const SizedBox(height: 16),

            // Target Content
            _buildTargetContent(),
            const SizedBox(height: 24),

            // Align Button
            _buildAlignButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignmentVisualization() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Your Sound Orb
        Column(
          children: [
            SoundOrb(
              size: 120,
              colors: const [AppColors.hotPink, AppColors.cosmicPurple, AppColors.teal],
              animate: _isAligning,
            ),
            const SizedBox(height: 12),
            Text(
              'YOUR SOUND',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: Colors.white.withAlpha(128),
                letterSpacing: 2,
              ),
            ),
          ],
        ),

        const SizedBox(width: 20),

        // Connection Indicator
        _resonanceScore > 0
            ? _buildCircularScore(_resonanceScore)
            : SizedBox(
                width: 80,
                height: 4,
                child: LinearProgressIndicator(
                  value: _alignmentProgress,
                  backgroundColor: Colors.white.withAlpha(26),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricYellow),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

        const SizedBox(width: 20),

        // Target Sound Orb
        Column(
          children: [
            SoundOrb(
              size: 120,
              colors: _getTargetColors(),
              animate: _isAligning,
            ),
            const SizedBox(height: 12),
            Text(
              _getTargetLabel().toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: Colors.white.withAlpha(128),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularScore(int score) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.white.withAlpha(26),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricYellow),
            strokeWidth: 4,
          ),
          Center(
            child: Text(
              '$score%',
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.electricYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getTargetColors() {
    if (_alignTarget == 'today') {
      return [AppColors.electricYellow, AppColors.hotPink, AppColors.cosmicPurple];
    } else if (_alignTarget == 'friend' && _selectedFriendId != null) {
      final friend = friends.firstWhere((f) => f['id'] == _selectedFriendId);
      return [friend['color1'] as Color, friend['color2'] as Color];
    }
    return [AppColors.cosmicPurple, AppColors.hotPink, AppColors.electricYellow];
  }

  String _getTargetLabel() {
    if (_alignTarget == 'today') return "Today's Sound";
    if (_alignTarget == 'friend' && _selectedFriendId != null) {
      final friend = friends.firstWhere((f) => f['id'] == _selectedFriendId);
      return friend['name'] as String;
    }
    return 'Select Target';
  }

  Widget _buildResonanceResult() {
    return GlassCard(
      child: Column(
        children: [
          Text(
            'Your frequencies are',
            style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(153)),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.electricYellow, AppColors.hotPink],
            ).createShader(bounds),
            child: Text(
              '$_resonanceScore% Aligned',
              style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          if (_dominantEnergy != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.electricYellow.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.electricYellow.withAlpha(51)),
              ),
              child: Text(
                _dominantEnergy!,
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricYellow,
                ),
              ),
            ),
          ],
          if (_alignmentDescription != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _alignmentDescription!,
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.white.withAlpha(179),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ResultButton(
                  label: 'Play Blend',
                  icon: Icons.play_arrow_rounded,
                  outlined: true,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultButton(
                  label: 'Save Moment',
                  icon: Icons.save_rounded,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetTabs() {
    return GlassCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _TabButton(label: 'Today', isActive: _alignTarget == 'today', onPressed: () {
            setState(() { _alignTarget = 'today'; _resetAlignment(); });
          }),
          _TabButton(label: 'Friend', isActive: _alignTarget == 'friend', onPressed: () {
            setState(() { _alignTarget = 'friend'; _resetAlignment(); });
          }),
          _TabButton(label: 'Transit', isActive: _alignTarget == 'transit', onPressed: () {
            setState(() { _alignTarget = 'transit'; _resetAlignment(); });
          }),
        ],
      ),
    );
  }

  Widget _buildTargetContent() {
    if (_alignTarget == 'today') return _buildTodayContent();
    if (_alignTarget == 'friend') return _buildFriendContent();
    return _buildTransitContent();
  }

  Widget _buildTodayContent() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.electricYellow, AppColors.hotPink]),
            ),
            child: const Icon(Icons.wb_sunny_rounded, color: AppColors.background, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Cosmic Sound", style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('December 12, 2025 • Scorpio Season', style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white.withAlpha(128))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendContent() {
    return Column(
      children: friends.map((friend) => _buildFriendItem(friend)).toList(),
    );
  }

  Widget _buildFriendItem(Map<String, dynamic> friend) {
    final isSelected = _selectedFriendId == friend['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderColor: isSelected ? AppColors.electricYellow.withAlpha(77) : null,
        backgroundColor: isSelected ? AppColors.electricYellow.withAlpha(26) : null,
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => setState(() { _selectedFriendId = friend['id'] as int; _resetAlignment(); }),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [friend['color1'] as Color, friend['color2'] as Color]),
                ),
                child: Center(child: Text((friend['name'] as String)[0], style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(friend['name'] as String, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('${friend['compatibility']}% compatible', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white.withAlpha(128))),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.electricYellow : Colors.white.withAlpha(26),
                ),
                child: Icon(Icons.check_rounded, size: 16, color: isSelected ? AppColors.background : Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransitContent() {
    return Column(
      children: upcomingTransits.map((transit) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: [AppColors.cosmicPurple, AppColors.hotPink]),
                ),
                child: const Icon(Icons.access_time_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transit['name'] as String, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('${transit['date']} • ${transit['energy']}', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white.withAlpha(128))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cosmicPurple.withAlpha(38),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Preview', style: GoogleFonts.syne(fontSize: 11, color: AppColors.cosmicPurple)),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildAlignButton() {
    final canAlign = !_isAligning && (_alignTarget != 'friend' || _selectedFriendId != null);
    return Container(
      decoration: BoxDecoration(
        gradient: canAlign ? const LinearGradient(colors: [AppColors.cosmicPurple, AppColors.hotPink]) : null,
        color: canAlign ? null : Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        boxShadow: canAlign ? [BoxShadow(color: AppColors.cosmicPurple.withAlpha(77), blurRadius: 20, offset: const Offset(0, 8))] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAlign ? _startAlignment : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isAligning)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                else
                  Icon(_resonanceScore > 0 ? Icons.refresh_rounded : Icons.access_time_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  _isAligning ? 'Aligning Frequencies...' : (_resonanceScore > 0 ? 'Align Again' : 'Begin Alignment'),
                  style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _TabButton({required this.label, required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isActive ? Colors.white.withAlpha(26) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? AppColors.electricYellow : Colors.white.withAlpha(128)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback onPressed;

  const _ResultButton({required this.label, required this.icon, this.outlined = false, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: outlined ? null : const LinearGradient(colors: [AppColors.electricYellow, Color(0xFFE5EB0D)]),
        color: outlined ? Colors.transparent : null,
        borderRadius: BorderRadius.circular(12),
        border: outlined ? Border.all(color: Colors.white.withAlpha(51)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: outlined ? Colors.white : AppColors.background),
                const SizedBox(width: 8),
                Text(label, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: outlined ? Colors.white : AppColors.background)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
