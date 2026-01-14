import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prescription.dart';
import '../services/audio_service.dart';

/// Tab content widget for the Prescribe mode in the Align screen.
/// Displays cosmic prescription with brainwave recommendations.
class PrescribeTab extends StatefulWidget {
  final CosmicPrescription? prescription;
  final bool isLoading;
  final String? error;
  final AudioService audioService;
  final VoidCallback? onRetry;

  const PrescribeTab({
    super.key,
    this.prescription,
    this.isLoading = false,
    this.error,
    required this.audioService,
    this.onRetry,
  });

  @override
  State<PrescribeTab> createState() => _PrescribeTabState();
}

class _PrescribeTabState extends State<PrescribeTab> {
  BrainwaveMode _selectedMode = BrainwaveMode.neutral;
  String _selectedCarrierPlanet = 'Sun';
  bool _isPlaying = false;
  bool _showSecondaryTransits = false;

  // Cosmic Octave frequencies for carrier override
  static const Map<String, double> _planetFrequencies = {
    'Sun': 126.22,
    'Moon': 210.42,
    'Mercury': 141.27,
    'Venus': 221.23,
    'Mars': 144.72,
    'Jupiter': 183.58,
    'Saturn': 147.85,
    'Uranus': 207.36,
    'Neptune': 211.44,
    'Pluto': 140.25,
  };

  @override
  void initState() {
    super.initState();
    _updateFromPrescription();
  }

  @override
  void didUpdateWidget(PrescribeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prescription != oldWidget.prescription) {
      _updateFromPrescription();
    }
  }

  void _updateFromPrescription() {
    if (widget.prescription != null) {
      setState(() {
        _selectedMode = widget.prescription!.recommendedMode;
        _selectedCarrierPlanet = widget.prescription!.carrierPlanet;
      });
    }
  }

  double get _currentCarrierHz => 
      _planetFrequencies[_selectedCarrierPlanet] ?? 126.22;

  void _togglePlayback() {
    if (_isPlaying) {
      widget.audioService.stop();
      setState(() => _isPlaying = false);
    } else {
      widget.audioService.playBinauralBeat(
        carrierHz: _currentCarrierHz,
        binauralHz: _selectedMode.hz,
        duration: 180.0, // 3 minutes
      );
      setState(() => _isPlaying = true);
      
      // Listen for playback end
      widget.audioService.playingStream.listen((playing) {
        if (!playing && mounted) {
          setState(() => _isPlaying = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }
    
    if (widget.error != null) {
      return _buildErrorState();
    }
    
    if (widget.prescription == null) {
      return _buildEmptyState();
    }

    final rx = widget.prescription!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Badge
        _buildAiBadge(),
        const SizedBox(height: 16),
        
        // Prescription Card
        _buildPrescriptionCard(rx),
        const SizedBox(height: 20),
        
        // Mode Selector
        _buildModeSelector(),
        const SizedBox(height: 16),
        
        // Carrier Frequency
        _buildCarrierSelector(),
        const SizedBox(height: 24),
        
        // Play Button
        _buildPlayButton(),
        
        // Secondary Transits (collapsible)
        if (rx.secondaryTransits.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSecondaryTransits(rx),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF9333EA),
          ),
          const SizedBox(height: 16),
          Text(
            'Reading your cosmic prescription...',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withAlpha(77)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 12),
          Text(
            'Unable to load prescription',
            style: GoogleFonts.syne(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.error ?? 'Unknown error',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white60,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withAlpha(51),
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Tap to load your cosmic prescription',
        style: GoogleFonts.spaceGrotesk(
          color: Colors.white60,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAiBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                'YOUR COSMIC PRESCRIPTION',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionCard(CosmicPrescription rx) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9333EA).withAlpha(38),
            const Color(0xFF1A1A2E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF9333EA).withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What's happening
          Text(
            rx.whatsHappening,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: Colors.white.withAlpha(230),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          
          // How it feels
          Text(
            rx.howItFeels,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white.withAlpha(179),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          
          // Recommendation box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF9333EA).withAlpha(38),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF9333EA).withAlpha(77),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_pharmacy,
                      color: Color(0xFF9333EA),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RECOMMENDED: ${rx.recommendedMode.displayName.toUpperCase()} (${rx.brainwaveHz.toStringAsFixed(0)} Hz)',
                      style: GoogleFonts.syne(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9333EA),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rx.whatItDoes,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: Colors.white.withAlpha(204),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BRAINWAVE MODE',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: Colors.white54,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BrainwaveMode.values.map((mode) {
            final isSelected = _selectedMode == mode;
            final isRecommended = widget.prescription?.recommendedMode == mode;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedMode = mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF9333EA), Color(0xFF6366F1)],
                        )
                      : null,
                  color: !isSelected ? Colors.white.withAlpha(13) : null,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF9333EA) 
                        : isRecommended 
                            ? const Color(0xFF9333EA).withAlpha(128)
                            : Colors.white.withAlpha(26),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      mode.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.displayName,
                      style: GoogleFonts.syne(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                    Text(
                      '${mode.hz.toStringAsFixed(0)} Hz',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        color: isSelected ? Colors.white70 : Colors.white38,
                      ),
                    ),
                    if (isRecommended && !isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9333EA).withAlpha(77),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '★',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 8,
                            color: const Color(0xFF9333EA),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCarrierSelector() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CARRIER FREQUENCY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: Colors.white54,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '♆',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha(179),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_selectedCarrierPlanet • ${_currentCarrierHz.toStringAsFixed(2)} Hz',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _showCarrierPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: Row(
              children: [
                Text(
                  'Override',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, size: 16, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCarrierPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Carrier Planet',
              style: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _planetFrequencies.entries.map((entry) {
                final isSelected = _selectedCarrierPlanet == entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCarrierPlanet = entry.key);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF9333EA), Color(0xFF6366F1)],
                            )
                          : null,
                      color: !isSelected ? Colors.white.withAlpha(13) : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF9333EA) 
                            : Colors.white.withAlpha(26),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          entry.key,
                          style: GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(2)} Hz',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _togglePlayback,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _isPlaying
              ? LinearGradient(
                  colors: [Colors.red.shade700, Colors.red.shade900],
                )
              : const LinearGradient(
                  colors: [Color(0xFF9333EA), Color(0xFF6366F1)],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (_isPlaying ? Colors.red : const Color(0xFF9333EA))
                  .withAlpha(77),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPlaying ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              _isPlaying ? 'STOP' : 'PLAY SOUND',
              style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryTransits(CosmicPrescription rx) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showSecondaryTransits = !_showSecondaryTransits),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  _showSecondaryTransits 
                      ? Icons.expand_less 
                      : Icons.expand_more,
                  color: Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Other Active Transits (${rx.secondaryTransits.length})',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showSecondaryTransits) ...[
          const SizedBox(height: 8),
          ...rx.secondaryTransits.map((transit) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: transit.nature == 'harmonious'
                          ? const Color(0xFF4ECDC4)
                          : transit.nature == 'challenging'
                              ? const Color(0xFFFF6B6B)
                              : Colors.white38,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    transit.description,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ],
    );
  }
}
