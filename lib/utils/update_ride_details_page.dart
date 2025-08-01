import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:travel_buddy/services/auth_service.dart';
import 'package:travel_buddy/widgets/location_autocomplete_field.dart';

class UpdateRideDetailsPage extends StatefulWidget {
  final dynamic rideDetails;
  final VoidCallback onRideUpdated;

  const UpdateRideDetailsPage({
    super.key,
    required this.rideDetails,
    required this.onRideUpdated,
  });

  @override
  UpdateRideDetailsPageState createState() => UpdateRideDetailsPageState();
}

class UpdateRideDetailsPageState extends State<UpdateRideDetailsPage> {
  final logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingUserData = true;
  bool _hasInitialized = false;
  String _message = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _initializeBasicFields();
    _loadUserPhoneNumber();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _initializeDateTimeFields();
      _hasInitialized = true;
    }
  }

  void _initializeBasicFields() {
    final ride = widget.rideDetails;

    _fromController.text = ride['from'] ?? '';
    _toController.text = ride['to'] ?? '';
    _capacityController.text = ride['capacity']?.toString() ?? '';
    _priceController.text = ride['price']?.toString() ?? '';
    _descriptionController.text = ride['description'] ?? '';

    if (ride['date'] != null) {
      try {
        final dateTime = DateTime.parse(ride['date']);
        _selectedDate = dateTime;
        _selectedTime = TimeOfDay.fromDateTime(dateTime);
        _dateController.text = DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        logger.e('Error parsing date', error: e);
      }
    }
  }

  void _initializeDateTimeFields() {
    if (_selectedTime != null) {
      _timeController.text = _selectedTime!.format(context);
    }
  }

  Future<void> _loadUserPhoneNumber() async {
    try {
      final ride = widget.rideDetails;
      if (ride['phoneNo'] != null) {
        if (mounted) {
          setState(() {
            _phoneController.text = ride['phoneNo'].toString();
            _isLoadingUserData = false;
          });
        }
        return;
      }

      final phoneNumber = await AuthService.getUserPhoneNumber();
      if (mounted && phoneNumber != null && phoneNumber.isNotEmpty) {
        setState(() {
          _phoneController.text = phoneNumber;
          _isLoadingUserData = false;
        });
      } else {
        final userData = await AuthService.getUserData();
        if (mounted && userData != null && userData['phoneNo'] != null) {
          setState(() {
            _phoneController.text = userData['phoneNo'].toString();
            _isLoadingUserData = false;
          });
        } else {
          if (mounted) {
            setState(() {
              _isLoadingUserData = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _capacityController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Ride'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 16),
              Text('Loading ride information...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Ride'), centerTitle: true, elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit, color: Colors.orange, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Edit Ride Details',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Update only the fields you wish to change. Others will remain unchanged.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (_message.isNotEmpty) ...[
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  _message.contains('success')
                                      ? Colors.green[50]
                                      : Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    _message.contains('success')
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                            child: Text(
                              _message,
                              style: TextStyle(
                                color:
                                    _message.contains('success')
                                        ? Colors.green[800]
                                        : Colors.red[800],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 16),
                        LocationAutocompleteField(
                          label: 'From',
                          controller: _fromController,
                          initialValue: _fromController.text,
                          onLocationSelected: (location) {
                            _fromController.text = location;
                          },
                        ),
                        SizedBox(height: 16),
                        LocationAutocompleteField(
                          label: 'To',
                          controller: _toController,
                          initialValue: _toController.text,
                          onLocationSelected: (location) {
                            _toController.text = location;
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dateController,
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    color: Colors.orange,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                readOnly: true,
                                onTap: _selectDate,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _timeController,
                                decoration: InputDecoration(
                                  labelText: 'Time',
                                  prefixIcon: Icon(
                                    Icons.access_time,
                                    color: Colors.orange,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                readOnly: true,
                                onTap: _selectTime,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a time';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ride Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _capacityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Capacity',
                                  prefixIcon: Icon(
                                    Icons.people,
                                    color: Colors.orange,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final capacity = int.tryParse(value);
                                  if (capacity == null ||
                                      capacity < 1 ||
                                      capacity > 8) {
                                    return 'Enter 1-8';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    color: Colors.orange,
                                  ),
                                  suffixIcon:
                                      _phoneController.text.isNotEmpty
                                          ? const Icon(
                                            Icons.verified,
                                            color: Colors.green,
                                          )
                                          : null,
                                  helperText:
                                      _phoneController.text.isNotEmpty
                                          ? 'Auto-filled from profile'
                                          : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (value.length < 10) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Price per seat (₹) - Optional',
                            prefixIcon: Icon(
                              Icons.currency_rupee,
                              color: Colors.orange,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description (Optional)',
                            prefixIcon: Icon(
                              Icons.description,
                              color: Colors.orange,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            hintText:
                                'Add any additional information about your ride...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateRide,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child:
                      _isLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Updating Ride...'),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save),
                              SizedBox(width: 8),
                              Text(
                                'Update Ride',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _updateRide() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final capacity = int.parse(_capacityController.text);
      final phoneNo = int.parse(_phoneController.text);
      final price =
          _priceController.text.isNotEmpty
              ? double.parse(_priceController.text)
              : null;

      DateTime? dateTime;
      if (_selectedDate != null && _selectedTime != null) {
        dateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      final updatedDetails = <String, dynamic>{};

      if (_fromController.text != widget.rideDetails['from']) {
        updatedDetails['from'] = _fromController.text;
      }
      if (_toController.text != widget.rideDetails['to']) {
        updatedDetails['to'] = _toController.text;
      }
      if (dateTime != null) {
        updatedDetails['date'] = dateTime.toIso8601String();
      }
      if (capacity != widget.rideDetails['capacity']) {
        updatedDetails['capacity'] = capacity;
      }
      if (phoneNo != widget.rideDetails['phoneNo']) {
        updatedDetails['phoneNo'] = phoneNo;
      }
      if (price != widget.rideDetails['price']) {
        updatedDetails['price'] = price;
      }
      if (_descriptionController.text != widget.rideDetails['description']) {
        updatedDetails['description'] = _descriptionController.text;
      }

      if (updatedDetails.isEmpty) {
        setState(() {
          _message = 'No changes detected';
          _isLoading = false;
        });
        return;
      }

      final result = await RideService.updateRideDetails(
        widget.rideDetails['_id'],
        updatedDetails,
      );

      setState(() {
        _isLoading = false;
        _message = result['message'];
      });

      if (result['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Ride updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        widget.onRideUpdated();
        Navigator.pop(context);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _message = 'Error updating ride: $error';
      });
    }
  }
}
