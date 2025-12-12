import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';

/// Connections (Friends) screen.
class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  String _filter = 'all';

  final connections = [
    {'id': 1, 'name': 'Maya Chen', 'sign': 'Pisces', 'color1': AppColors.hotPink, 'color2': AppColors.cosmicPurple, 'compatibility': 91, 'lastAligned': '2 hours ago', 'status': 'online', 'mutualPlanets': ['Moon', 'Venus']},
    {'id': 2, 'name': 'Jordan Rivera', 'sign': 'Aries', 'color1': AppColors.electricYellow, 'color2': AppColors.hotPink, 'compatibility': 78, 'lastAligned': 'Yesterday', 'status': 'online', 'mutualPlanets': ['Mars', 'Sun']},
    {'id': 3, 'name': 'Alex Kim', 'sign': 'Scorpio', 'color1': AppColors.cosmicPurple, 'color2': AppColors.teal, 'compatibility': 87, 'lastAligned': '3 days ago', 'status': 'offline', 'mutualPlanets': ['Pluto', 'Moon']},
    {'id': 4, 'name': 'Sam Taylor', 'sign': 'Leo', 'color1': AppColors.teal, 'color2': AppColors.electricYellow, 'compatibility': 65, 'lastAligned': '1 week ago', 'status': 'offline', 'mutualPlanets': ['Sun']},
    {'id': 5, 'name': 'Riley Morgan', 'sign': 'Libra', 'color1': AppColors.orange, 'color2': AppColors.hotPink, 'compatibility': 82, 'lastAligned': '4 days ago', 'status': 'online', 'mutualPlanets': ['Venus', 'Mercury']},
  ];

  final pendingRequests = [
    {'id': 101, 'name': 'Chris Lee', 'sign': 'Capricorn', 'color1': AppColors.cosmicPurple, 'color2': AppColors.electricYellow},
    {'id': 102, 'name': 'Pat Johnson', 'sign': 'Gemini', 'color1': AppColors.hotPink, 'color2': AppColors.teal},
  ];

  Color _getCompatibilityColor(int score) {
    if (score >= 85) return AppColors.teal;
    if (score >= 70) return AppColors.electricYellow;
    if (score >= 50) return AppColors.orange;
    return AppColors.red;
  }

  List<Map<String, dynamic>> get filteredConnections {
    final sorted = List<Map<String, dynamic>>.from(connections);
    if (_filter == 'compatible') {
      sorted.sort((a, b) => (b['compatibility'] as int).compareTo(a['compatibility'] as int));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              showBackButton: true,
              showMenuButton: false,
              title: 'Connections',
              rightAction: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.cosmicPurple, AppColors.hotPink]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 20),

            // Filter Buttons
            _buildFilterButtons(),
            const SizedBox(height: 24),

            // Pending Requests
            if (pendingRequests.isNotEmpty) ...[
              _buildPendingRequests(),
              const SizedBox(height: 24),
            ],

            // Connections List
            _buildConnectionsList(),
          ],
        ),
      ),
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
              style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search connections...',
                hintStyle: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(102)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
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
              child: Text('${pendingRequests.length}', style: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.background)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pendingRequests.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildPendingRequestCard(pendingRequests[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingRequestCard(Map<String, dynamic> request) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [request['color1'] as Color, request['color2'] as Color]),
              ),
              child: Center(child: Text((request['name'] as String)[0], style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
            const SizedBox(height: 12),
            Text(request['name'] as String, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            Text(request['sign'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(icon: Icons.close_rounded, color: Colors.white.withAlpha(26), onPressed: () {}),
                const SizedBox(width: 8),
                _ActionButton(icon: Icons.check_rounded, color: AppColors.teal, onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Cosmic Circle (${connections.length})', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withAlpha(179))),
        const SizedBox(height: 12),
        ...filteredConnections.map((connection) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildConnectionCard(connection),
        )),
      ],
    );
  }

  Widget _buildConnectionCard(Map<String, dynamic> connection) {
    final compatColor = _getCompatibilityColor(connection['compatibility'] as int);
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [connection['color1'] as Color, connection['color2'] as Color]),
                ),
                child: Center(
                  child: Text(
                    (connection['name'] as String).split(' ').map((n) => n[0]).join(''),
                    style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              if (connection['status'] == 'online')
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.backgroundMid, width: 3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(connection['name'] as String, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withAlpha(13), borderRadius: BorderRadius.circular(10)),
                      child: Text(connection['sign'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(102))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: compatColor, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('${connection['compatibility']}%', style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: compatColor)),
                    const SizedBox(width: 12),
                    Text('Aligned ${connection['lastAligned']}', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(102))),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: (connection['mutualPlanets'] as List).map((planet) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(13), borderRadius: BorderRadius.circular(8)),
                    child: Text('${_getPlanetSymbol(planet)} $planet', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white.withAlpha(128))),
                  )).toList(),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.cosmicPurple, AppColors.hotPink]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.cosmicPurple.withAlpha(77), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: IconButton(
              icon: const Icon(Icons.access_time_rounded, color: Colors.white, size: 18),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanetSymbol(String planet) {
    switch (planet) {
      case 'Moon': return '☽';
      case 'Sun': return '☉';
      case 'Venus': return '♀';
      case 'Mars': return '♂';
      case 'Mercury': return '☿';
      case 'Pluto': return '♇';
      default: return '✦';
    }
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
