import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/design_tokens.dart';
import '../../models/event_data.dart';

class EventMap extends StatefulWidget {
  final List<Event> events;
  final LatLng userLocation;
  final Function(Event) onEventSelected;

  const EventMap({
    super.key,
    required this.events,
    required this.userLocation,
    required this.onEventSelected,
  });

  @override
  State<EventMap> createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.userLocation, // Use user location
        initialZoom: 13.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Disable rotation for simplicity
        ),
      ),
      children: [
        // Dark Mode Map Tiles (CartoDB Dark Matter)
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.astrofm.app', // Replace with actual package name
        ),
        
        // Markers
        MarkerLayer(
          markers: [
            // User Location Marker
            Marker(
              point: widget.userLocation,
              width: 80,
              height: 80,
              child: _buildUserLocationMarker(),
            ),
            
            // Event Markers
            ...widget.events.map((event) => Marker(
              point: LatLng(event.latitude, event.longitude),
              width: 60,
              height: 60,
              child: GestureDetector(
                onTap: () => widget.onEventSelected(event),
                child: _buildEventMarker(event),
              ),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.electricYellow.withAlpha(30),
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.electricYellow,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricYellow.withAlpha(200),
                blurRadius: 10,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventMarker(Event event) {
    final Color color = _getEventColor(event);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withAlpha(150), Colors.transparent],
            ),
          ),
        ),
        // Orb
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white.withAlpha(200), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color,
                blurRadius: 6,
                spreadRadius: 2,
              )
            ],
          ),
        ),
      ],
    );
  }

  Color _getEventColor(Event event) {
    // Basic logic mapping tags to colors (can match EventCard logic)
    final tag = event.vibeTags.firstOrNull?.toLowerCase() ?? '';
    if (tag.contains('fire')) return AppColors.red;
    if (tag.contains('water')) return AppColors.teal;
    if (tag.contains('earth')) return AppColors.hotPink;
    return AppColors.cosmicPurple;
  }
}
