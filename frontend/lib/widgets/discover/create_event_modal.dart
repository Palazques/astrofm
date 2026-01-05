/// Create Event Modal for Discover page.
/// 
/// Allows users to create social events with:
/// - Event type selection grid
/// - Name, Date, Time, Location fields
/// - Cosmic Intention textarea

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../models/event_data.dart';
import '../../services/discover_service.dart';
import '../glass_card.dart';

class CreateEventModal extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;
  final VoidCallback? onEventCreated;

  const CreateEventModal({
    super.key,
    required this.userLatitude,
    required this.userLongitude,
    this.onEventCreated,
  });

  @override
  State<CreateEventModal> createState() => _CreateEventModalState();
}

class _CreateEventModalState extends State<CreateEventModal> {
  final _formKey = GlobalKey<FormState>();
  
  EventType? _selectedType;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _intentionController = TextEditingController();
  final _priceController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _intentionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.electricYellow,
              onPrimary: Colors.black,
              surface: AppColors.backgroundMid,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.electricYellow,
              onPrimary: Colors.black,
              surface: AppColors.backgroundMid,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      setState(() => _errorMessage = 'Please select an event type');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      double? price;
      if (_priceController.text.isNotEmpty) {
        price = double.tryParse(_priceController.text);
      }

      final request = CreateEventRequest(
        title: _titleController.text,
        description: _descriptionController.text,
        locationName: _locationController.text,
        latitude: widget.userLatitude,
        longitude: widget.userLongitude,
        date: eventDateTime,
        eventType: _selectedType!,
        price: price,
        cosmicIntention: _intentionController.text.isNotEmpty 
            ? _intentionController.text 
            : null,
      );

      await discoverService.createEvent(request);
      
      if (mounted) {
        widget.onEventCreated?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to create event: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'CREATE EVENT',
                  style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Type Selection
                    Text(
                      'EVENT TYPE',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: EventType.values.map((type) {
                        final isSelected = _selectedType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = type),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.electricYellow.withAlpha(51)
                                  : Colors.white.withAlpha(13),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.electricYellow
                                    : Colors.white.withAlpha(51),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  type.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  type.displayName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isSelected
                                        ? AppColors.electricYellow
                                        : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Event Name
                    _buildTextField(
                      controller: _titleController,
                      label: 'EVENT NAME',
                      hint: 'Full Moon Sound Bath',
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'DESCRIPTION',
                      hint: 'Describe your event...',
                      maxLines: 3,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date & Time Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimeField(
                            label: 'DATE',
                            value: '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                            icon: Icons.calendar_today,
                            onTap: _selectDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateTimeField(
                            label: 'TIME',
                            value: _selectedTime.format(context),
                            icon: Icons.schedule,
                            onTap: _selectTime,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Location
                    _buildTextField(
                      controller: _locationController,
                      label: 'LOCATION',
                      hint: 'The Sanctuary, LA',
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Price (optional)
                    _buildTextField(
                      controller: _priceController,
                      label: 'PRICE (OPTIONAL)',
                      hint: '25 (leave empty for free)',
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Cosmic Intention
                    _buildTextField(
                      controller: _intentionController,
                      label: 'COSMIC INTENTION (OPTIONAL)',
                      hint: 'What energy do you want to cultivate?',
                      maxLines: 2,
                    ),
                    
                    // Error Message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricYellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'CREATE EVENT',
                                style: GoogleFonts.syne(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
            filled: true,
            fillColor: Colors.white.withAlpha(13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withAlpha(51)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withAlpha(51)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.electricYellow),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(51)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.white54),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
