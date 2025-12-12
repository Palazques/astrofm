import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location.dart';
import '../services/api_service.dart';

/// A location autocomplete widget that searches for cities as the user types.
class LocationAutocomplete extends StatefulWidget {
  /// Called when a location is selected.
  final ValueChanged<Location> onLocationSelected;

  /// Initial location to display, if any.
  final Location? initialLocation;

  /// Placeholder text for the input field.
  final String hintText;

  const LocationAutocomplete({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
    this.hintText = 'Enter birth city...',
  });

  @override
  State<LocationAutocomplete> createState() => _LocationAutocompleteState();
}

class _LocationAutocompleteState extends State<LocationAutocomplete> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _apiService = ApiService();

  List<Location> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  Location? _selectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
      _controller.text = widget.initialLocation!.displayName;
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Delay hiding to allow tap on suggestion
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    }
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear selection if text changed
    if (_selectedLocation != null &&
        query != _selectedLocation!.displayName) {
      _selectedLocation = null;
    }

    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Debounce: wait 300ms before searching
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchLocations(query);
    });
  }

  Future<void> _searchLocations(String query) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final results = await _apiService.searchLocations(query);

    if (mounted) {
      setState(() {
        _suggestions = results;
        _showSuggestions = results.isNotEmpty;
        _isLoading = false;
      });
    }
  }

  void _onLocationSelected(Location location) {
    setState(() {
      _selectedLocation = location;
      _controller.text = location.displayName;
      _showSuggestions = false;
      _suggestions = [];
    });
    _focusNode.unfocus();
    widget.onLocationSelected(location);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Birth Place',
            hintText: widget.hintText,
            labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
            hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
            filled: true,
            fillColor: Colors.white.withAlpha(8),
            prefixIcon: Icon(
              Icons.location_on,
              color: _selectedLocation != null
                  ? const Color(0xFFFFEB3B)
                  : Colors.white.withAlpha(153),
            ),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFFEB3B)),
                      ),
                    ),
                  )
                : _selectedLocation != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _selectedLocation = null;
                            _suggestions = [];
                          });
                        },
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withAlpha(26)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _selectedLocation != null
                    ? const Color(0xFFFFEB3B).withAlpha(128)
                    : Colors.white.withAlpha(26),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFEB3B)),
            ),
          ),
          validator: (value) {
            if (_selectedLocation == null) {
              return 'Please select a location';
            }
            return null;
          },
        ),

        // Suggestions dropdown
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(26)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(128),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final location = _suggestions[index];
                  return _buildSuggestionTile(location, index);
                },
              ),
            ),
          ),

        // Selected location info
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, '
              'Lon: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withAlpha(128),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSuggestionTile(Location location, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onLocationSelected(location),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: index > 0
                ? Border(
                    top: BorderSide(color: Colors.white.withAlpha(13)),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.place,
                size: 20,
                color: const Color(0xFFFF1493).withAlpha(179),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.city ?? location.displayName.split(',').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatSubtitle(location),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                location.countryCode,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withAlpha(102),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSubtitle(Location location) {
    final parts = <String>[];
    if (location.state != null && location.state!.isNotEmpty) {
      parts.add(location.state!);
    }
    parts.add(location.country);
    return parts.join(', ');
  }
}
