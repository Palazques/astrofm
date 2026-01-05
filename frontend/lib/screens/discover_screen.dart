/// Discover screen for event discovery with astrological alignment.
/// 
/// Features:
/// - GPS location access for nearby events
/// - Seasonal guidance card with zodiac season info
/// - Smart filtering (Aligned/Nearby/All + distance slider)
/// - Event cards with alignment badges
/// - Create event FAB

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../config/design_tokens.dart';
import '../models/event_data.dart';
import '../services/discover_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../widgets/discover/event_map.dart';
import '../widgets/discover/event_card.dart';
import '../widgets/discover/seasonal_guidance_card.dart';
import '../widgets/discover/discover_filter_bar.dart';
import '../widgets/discover/create_event_modal.dart';

/// Map sign to element for user element extraction.
const Map<String, String> _signToElement = {
  'Aries': 'Fire', 'Leo': 'Fire', 'Sagittarius': 'Fire',
  'Taurus': 'Earth', 'Virgo': 'Earth', 'Capricorn': 'Earth',
  'Gemini': 'Air', 'Libra': 'Air', 'Aquarius': 'Air',
  'Cancer': 'Water', 'Scorpio': 'Water', 'Pisces': 'Water',
};

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  // Data state
  List<Event> _events = [];
  SeasonalGuidance? _seasonalGuidance;
  bool _isLoading = true;
  String? _error;
  
  // Location state
  LatLng? _userLocation;
  bool _locationLoading = true;
  
  // Filter state
  DiscoverFilter _currentFilter = DiscoverFilter.aligned;
  double _distanceMiles = 25.0;
  List<EventType> _selectedEventTypes = [];
  bool _showEventTypeFilters = false;
  
  // User elements from birth chart
  List<String> _userElements = [];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await Future.wait([
      _loadLocation(),
      _loadUserElements(),
      _loadSeasonalGuidance(),
    ]);
    await _loadEvents();
  }

  Future<void> _loadLocation() async {
    try {
      final location = await locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _userLocation = location;
          _locationLoading = false;
        });
      }
    } catch (e) {
      print('Error loading location: $e');
      // Fall back to default LA location
      if (mounted) {
        setState(() {
          _userLocation = const LatLng(34.0522, -118.2437);
          _locationLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserElements() async {
    // Note: BirthData doesn't store computed signs (Sun/Moon/Rising).
    // To get user elements, we would need to call the natal chart API.
    // For now, we'll rely on the seasonal element for alignment scoring.
    // User elements will be empty, which means scoring will use seasonal only.
    
    // TODO: In the future, store computed chart data in local storage
    // or fetch it here to extract user's dominant elements.
    
    // For now, just leave _userElements empty - the backend will still
    // score events based on seasonal element.
    setState(() {
      _userElements = [];
    });
  }

  Future<void> _loadSeasonalGuidance() async {
    try {
      final guidance = await discoverService.getSeasonalGuidance();
      if (mounted) {
        setState(() {
          _seasonalGuidance = guidance;
        });
      }
    } catch (e) {
      print('Error loading seasonal guidance: $e');
    }
  }

  Future<void> _loadEvents() async {
    if (_userLocation == null) return;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final events = await discoverService.getEvents(
        latitude: _userLocation!.latitude,
        longitude: _userLocation!.longitude,
        radiusMiles: _distanceMiles,
        userElements: _userElements.isNotEmpty ? _userElements : null,
        filter: _currentFilter,
        eventTypes: _selectedEventTypes.isNotEmpty ? _selectedEventTypes : null,
      );

      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not find cosmic events near you.';
          _isLoading = false;
        });
      }
    }
  }

  void _onFilterChanged(DiscoverFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
    _loadEvents();
  }

  void _onDistanceChanged(double distance) {
    setState(() {
      _distanceMiles = distance;
    });
    // Debounce - only reload on release
  }

  void _onDistanceChangeEnd(double distance) {
    _loadEvents();
  }

  void _onEventTypeToggle(EventType type) {
    setState(() {
      if (_selectedEventTypes.contains(type)) {
        _selectedEventTypes.remove(type);
      } else {
        _selectedEventTypes.add(type);
      }
    });
    _loadEvents();
  }

  void _toggleEventTypeFilters() {
    setState(() {
      _showEventTypeFilters = !_showEventTypeFilters;
    });
  }

  void _onEventSelected(Event event) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundMid,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            EventCard(event: event),
          ],
        ),
      ),
    );
  }

  void _showCreateEventModal() {
    if (_userLocation == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CreateEventModal(
        userLatitude: _userLocation!.latitude,
        userLongitude: _userLocation!.longitude,
        onEventCreated: () {
          _loadEvents();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateEventModal,
        backgroundColor: AppColors.electricYellow,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Stack(
        children: [
          // 1. Map Layer (Full Screen)
          if (_userLocation != null)
            Positioned.fill(
              child: EventMap(
                events: _events,
                userLocation: _userLocation!,
                onEventSelected: _onEventSelected,
              ),
            )
          else
            Positioned.fill(
              child: Container(
                color: AppColors.background,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // 2. Content Overlay
          SafeArea(
            child: Column(
              children: [
                // Seasonal Guidance Card
                if (_seasonalGuidance != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SeasonalGuidanceCard(
                      guidance: _seasonalGuidance!,
                      selectedEventTypes: _selectedEventTypes,
                      onEventTypeToggle: _onEventTypeToggle,
                    ),
                  ),
                
                // Filter Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DiscoverFilterBar(
                    currentFilter: _currentFilter,
                    onFilterChanged: _onFilterChanged,
                    distanceMiles: _distanceMiles,
                    onDistanceChanged: _onDistanceChanged,
                    selectedEventTypes: _selectedEventTypes,
                    onEventTypeToggle: _onEventTypeToggle,
                    showEventTypes: _showEventTypeFilters,
                    onToggleEventTypes: _toggleEventTypeFilters,
                  ),
                ),
              ],
            ),
          ),
          
          // 3. Bottom Sheet (Events List)
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.15,
            maxChildSize: 0.75,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid.withAlpha(245),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    // Title Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getListTitle(),
                            style: GoogleFonts.syne(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              if (!_isLoading)
                                Text(
                                  '${_events.length} events',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              if (_isLoading)
                                const SizedBox(
                                  width: 14, 
                                  height: 14, 
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.teal,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Events List
                    Expanded(
                      child: _buildEventsList(scrollController),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getListTitle() {
    switch (_currentFilter) {
      case DiscoverFilter.aligned:
        return 'ALIGNED FOR YOU';
      case DiscoverFilter.nearby:
        return 'NEARBY EVENTS';
      case DiscoverFilter.all:
        return 'ALL EVENTS';
    }
  }

  Widget _buildEventsList(ScrollController scrollController) {
    if (_isLoading && _events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.teal),
            SizedBox(height: 16),
            Text(
              'Finding cosmic events...',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadEvents,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore_off, color: Colors.white38, size: 48),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: GoogleFonts.syne(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or distance',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return EventCard(
          event: _events[index],
          onTap: () => _onEventSelected(_events[index]),
        );
      },
    );
  }
}
