import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../models/location.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/location_autocomplete.dart';
import 'chart_screen.dart';

/// Birth data input screen for onboarding or editing birth data.
class BirthInputScreen extends StatefulWidget {
  const BirthInputScreen({super.key});

  @override
  State<BirthInputScreen> createState() => _BirthInputScreenState();
}

class _BirthInputScreenState extends State<BirthInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  DateTime _selectedDate = DateTime(1990, 1, 1);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  Location? _selectedLocation;

  bool _isLoading = false;
  bool _isBackendConnected = false;

  @override
  void initState() {
    super.initState();
    _checkBackendConnection();
  }

  Future<void> _checkBackendConnection() async {
    final isConnected = await _apiService.checkHealth();
    if (mounted) {
      setState(() => _isBackendConnected = isConnected);
    }
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _calculateChart() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a birth location'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final datetime = '${_selectedDate.year.toString().padLeft(4, '0')}-'
          '${_selectedDate.month.toString().padLeft(2, '0')}-'
          '${_selectedDate.day.toString().padLeft(2, '0')}T'
          '${_selectedTime.hour.toString().padLeft(2, '0')}:'
          '${_selectedTime.minute.toString().padLeft(2, '0')}:00';

      final chart = await _apiService.calculateNatalChart(
        datetime: datetime,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        timezone: 'UTC',
      );

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChartScreen(chart: chart)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.electricYellow, AppColors.hotPink],
                      ).createShader(bounds),
                      child: Text(
                        'ASTRO.FM',
                        style: GoogleFonts.syne(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Your Cosmic Sound Profile',
                      style: GoogleFonts.spaceGrotesk(fontSize: 16, color: Colors.white.withAlpha(179), letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Connection Status
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: (_isBackendConnected ? Colors.green : Colors.red).withAlpha(51),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: (_isBackendConnected ? Colors.green : Colors.red).withAlpha(128)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: _isBackendConnected ? Colors.green : Colors.red, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(_isBackendConnected ? 'Backend Connected' : 'Backend Offline', style: TextStyle(color: _isBackendConnected ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Birth Data Card
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BIRTH DATA', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.hotPink, letterSpacing: 2)),
                        const SizedBox(height: 24),

                        _buildInputTile(Icons.calendar_today, 'Birth Date', '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}', _selectDate),
                        const SizedBox(height: 16),
                        _buildInputTile(Icons.access_time, 'Birth Time', _selectedTime.format(context), _selectTime),
                        const SizedBox(height: 24),

                        LocationAutocomplete(
                          initialLocation: _selectedLocation,
                          onLocationSelected: (location) => setState(() => _selectedLocation = location),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Calculate Button
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.electricYellow, AppColors.hotPink]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: AppColors.hotPink.withAlpha(102), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading || !_isBackendConnected ? null : _calculateChart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                          : Text('CALCULATE MY CHART', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputTile(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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
            Icon(icon, color: AppColors.electricYellow, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white.withAlpha(153))),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withAlpha(102)),
          ],
        ),
      ),
    );
  }
}
