import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../models/location.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';
import '../../widgets/onboarding/onboarding_heading.dart';
import '../../widgets/onboarding/onboarding_cta.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/location_autocomplete.dart';

/// Screen 3: Birth data input (date, time, location).
class BirthDataScreen extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final Location? initialLocation;
  final bool initialTimeUnknown;
  final Function({
    required DateTime date,
    TimeOfDay? time,
    required Location location,
    required bool timeUnknown,
  }) onNext;
  final VoidCallback onBack;

  const BirthDataScreen({
    super.key,
    this.initialDate,
    this.initialTime,
    this.initialLocation,
    this.initialTimeUnknown = false,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BirthDataScreen> createState() => _BirthDataScreenState();
}

class _BirthDataScreenState extends State<BirthDataScreen> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  Location? _selectedLocation;
  bool _birthTimeUnknown = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime(1990, 1, 1);
    _selectedTime = widget.initialTime;
    _selectedLocation = widget.initialLocation;
    _birthTimeUnknown = widget.initialTimeUnknown;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.electricYellow,
            onPrimary: Colors.black,
            surface: AppColors.backgroundMid,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.hotPink,
            onPrimary: Colors.white,
            surface: AppColors.backgroundMid,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _birthTimeUnknown = false;
      });
    }
  }

  void _validateAndProceed() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select your birth location',
            style: GoogleFonts.spaceGrotesk(),
          ),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    widget.onNext(
      date: _selectedDate,
      time: _birthTimeUnknown ? null : _selectedTime,
      location: _selectedLocation!,
      timeUnknown: _birthTimeUnknown,
    );
  }

  void _showWhyModal() {
    final reasons = [
      {
        'icon': Icons.public,
        'title': 'Planetary Positions',
        'description': 'Planets were in specific positions when you were born.',
        'color': AppColors.electricYellow,
      },
      {
        'icon': Icons.arrow_upward,
        'title': 'Rising Sign',
        'description': 'Your ascendant sign shapes your cosmic personality.',
        'color': AppColors.hotPink,
      },
      {
        'icon': Icons.music_note,
        'title': 'Unique Sound',
        'description': 'Your birth chart creates your personal frequency.',
        'color': AppColors.teal,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Why we need your birth data',
              style: GoogleFonts.syne(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            ...reasons.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (r['color'] as Color).withAlpha(38),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(r['icon'] as IconData, color: r['color'] as Color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['title'] as String, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(r['description'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white.withAlpha(153))),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Text(
              'Your data is encrypted and never shared.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: Colors.white.withAlpha(102),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _selectedLocation != null;

    return OnboardingScaffold(
      step: 3,
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Heading
            const OnboardingHeading(
              title: 'When & where were you born?',
              subtitle: 'We\'ll use this to calculate your unique cosmic signature.',
            ),
            const SizedBox(height: 32),

            // Birth data card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date selector
                  _buildInputTile(
                    icon: Icons.calendar_today,
                    label: 'Birth Date',
                    value: _formatDate(_selectedDate),
                    accentColor: AppColors.electricYellow,
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 16),

                  // Time selector
                  _buildInputTile(
                    icon: Icons.access_time,
                    label: 'Birth Time',
                    value: _birthTimeUnknown
                        ? 'Unknown'
                        : _selectedTime?.format(context) ?? 'Tap to select',
                    accentColor: AppColors.hotPink,
                    onTap: _selectTime,
                    isDisabled: _birthTimeUnknown,
                  ),

                  // "I don't know my birth time" checkbox
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _birthTimeUnknown = !_birthTimeUnknown;
                        if (_birthTimeUnknown) {
                          _selectedTime = null;
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _birthTimeUnknown
                                ? AppColors.cosmicPurple.withAlpha(51)
                                : Colors.white.withAlpha(13),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _birthTimeUnknown
                                  ? AppColors.cosmicPurple
                                  : Colors.white.withAlpha(51),
                            ),
                          ),
                          child: _birthTimeUnknown
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.cosmicPurple,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'I don\'t know my birth time',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: Colors.white.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location autocomplete
                  LocationAutocomplete(
                    initialLocation: _selectedLocation,
                    onLocationSelected: (location) {
                      setState(() => _selectedLocation = location);
                    },
                    hintText: 'Enter birth city...',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Why we need this button
            GestureDetector(
              onTap: _showWhyModal,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(26)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: AppColors.cosmicPurple,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Why do we need this?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppColors.cosmicPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Continue button
            OnboardingCta(
              label: 'Continue',
              onPressed: _validateAndProceed,
              isDisabled: !isValid,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInputTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(26)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDisabled ? Colors.white.withAlpha(77) : accentColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: Colors.white.withAlpha(153),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.syne(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDisabled
                          ? Colors.white.withAlpha(102)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withAlpha(102),
            ),
          ],
        ),
      ),
    );
  }
}
