import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/natal_chart.dart';

/// Screen to display the calculated natal chart.
class ChartScreen extends StatelessWidget {
  final NatalChart chart;

  const ChartScreen({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D1A),
              Color(0xFF1E1E2E),
              Color(0xFF2D1B4E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Chart Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ascendant Card
                      _buildAscendantCard(),
                      const SizedBox(height: 24),
                      
                      // Planets Section
                      _buildSectionTitle('PLANETARY POSITIONS'),
                      const SizedBox(height: 16),
                      ...chart.planets.map((planet) => _buildPlanetCard(planet)),
                      
                      // Done Button
                      const SizedBox(height: 32),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFEB3B), Color(0xFFFF1493)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF1493).withAlpha(77),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Pop back to Profile screen (through birth-input)
                            Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'DONE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'YOUR NATAL CHART',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Color(0xFFFFEB3B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => _shareChart(),
            icon: const Icon(Icons.share_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _shareChart() {
    final planets = chart.planets.map((p) => '• ${p.name}: ${p.sign} ${p.signDegree.toStringAsFixed(1)}°${p.retrogradeSymbol}').join('\n');
    
    final text = '''✨ MY NATAL CHART

⭐ Ascendant: ${chart.formattedAscendant}

🌟 PLANETARY POSITIONS
$planets

— Discover your cosmic blueprint at Astro.FM''';
    
    Share.share(text);
  }

  Widget _buildAscendantCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF1493).withAlpha(51),
            const Color(0xFFFFEB3B).withAlpha(51),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withAlpha(26),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wb_sunny,
            size: 48,
            color: Color(0xFFFFEB3B),
          ),
          const SizedBox(height: 16),
          const Text(
            'ASCENDANT',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            chart.formattedAscendant,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Birth: ${chart.birthDatetime}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        color: Color(0xFFFF1493),
      ),
    );
  }

  Widget _buildPlanetCard(PlanetPosition planet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(26),
        ),
      ),
      child: Row(
        children: [
          // Planet Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getPlanetColor(planet.name).withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _getPlanetSymbol(planet.name),
                style: TextStyle(
                  fontSize: 24,
                  color: _getPlanetColor(planet.name),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Planet Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      planet.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    if (planet.retrograde)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Rx',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  planet.formattedPosition,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFFEB3B),
                  ),
                ),
              ],
            ),
          ),
          
          // House Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF1493).withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'HOUSE',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white54,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${planet.house}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF1493),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanetSymbol(String name) {
    const symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mercury': '☿',
      'Venus': '♀',
      'Mars': '♂',
      'Jupiter': '♃',
      'Saturn': '♄',
      'Uranus': '♅',
      'Neptune': '♆',
      'Pluto': '♇',
    };
    return symbols[name] ?? '★';
  }

  Color _getPlanetColor(String name) {
    const colors = {
      'Sun': Color(0xFFFFD700),
      'Moon': Color(0xFFC0C0C0),
      'Mercury': Color(0xFF87CEEB),
      'Venus': Color(0xFFFF69B4),
      'Mars': Color(0xFFFF4500),
      'Jupiter': Color(0xFFFF8C00),
      'Saturn': Color(0xFF8B4513),
      'Uranus': Color(0xFF00CED1),
      'Neptune': Color(0xFF4169E1),
      'Pluto': Color(0xFF800080),
    };
    return colors[name] ?? Colors.white;
  }
}
