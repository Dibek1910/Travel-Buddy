import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/auth_service.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:travel_buddy/widgets/location_autocomplete_field.dart';

class CreateRidePage extends StatefulWidget {
  final String authToken;

  const CreateRidePage({super.key, required this.authToken});

  @override
  CreateRidePageState createState() => CreateRidePageState();
}

class CreateRidePageState extends State<CreateRidePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingUserData = true;
  bool _isFormValid = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _fromLocationSelected = false;
  bool _toLocationSelected = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  bool _capacityValid = false;
  bool _phoneValid = false;
  bool _priceValid = false;
  bool _descriptionValid = false;

  @override
  void initState() {
    super.initState();
    _loadUserPhoneNumber();
    _setupFieldListeners();
  }

  void _setupFieldListeners() {
    _capacityController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _priceController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPhoneNumber() async {
    try {
      final phoneNumber = await AuthService.getUserPhoneNumber();
      if (mounted && phoneNumber != null && phoneNumber.isNotEmpty) {
        setState(() {
          _phoneController.text = phoneNumber;
          _isLoadingUserData = false;
        });
        _validateForm();
      } else {
        final userData = await AuthService.getUserData();
        if (mounted && userData != null && userData['phoneNo'] != null) {
          setState(() {
            _phoneController.text = userData['phoneNo'];
            _isLoadingUserData = false;
          });
          _validateForm();
        } else {
          setState(() {
            _isLoadingUserData = false;
          });
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

  void _validateForm() {
    setState(() {
      _fromLocationSelected = _fromController.text.trim().isNotEmpty;
      _toLocationSelected = _toController.text.trim().isNotEmpty;
      _dateSelected = _dateController.text.trim().isNotEmpty;
      _timeSelected = _timeController.text.trim().isNotEmpty;

      final capacity = int.tryParse(_capacityController.text.trim());
      _capacityValid = capacity != null && capacity >= 1 && capacity <= 8;

      final phoneRegex = RegExp(r'^[6-9]\d{9}$');
      _phoneValid = phoneRegex.hasMatch(_phoneController.text.trim());

      final price = double.tryParse(_priceController.text.trim());
      _priceValid =
          _priceController.text.trim().isNotEmpty &&
          price != null &&
          price >= 0 &&
          price <= 10000;

      _descriptionValid =
          _descriptionController.text.trim().isNotEmpty &&
          _descriptionController.text.trim().length >= 5 &&
          _descriptionController.text.trim().length <= 500;

      _isFormValid =
          _fromLocationSelected &&
          _toLocationSelected &&
          _dateSelected &&
          _timeSelected &&
          _capacityValid &&
          _phoneValid &&
          _priceValid &&
          _descriptionValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 16),
              Text('Loading user information...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              Icon(
                                Icons.add_circle,
                                color: Colors.orange,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Create New Ride',
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
                            'Share your journey with others',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
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
                          Row(
                            children: [
                              Text(
                                'Route Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '*',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'From',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              LocationAutocompleteField(
                                label: 'Pickup Location',
                                controller: _fromController,
                                hintText: 'Enter pickup location',
                                onLocationSelected: (location) {
                                  _fromController.text = location;
                                  _validateForm();
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'To',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              LocationAutocompleteField(
                                label: 'Destination',
                                controller: _toController,
                                hintText: 'Enter destination',
                                onLocationSelected: (location) {
                                  _toController.text = location;
                                  _validateForm();
                                },
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
                          Row(
                            children: [
                              Text(
                                'Date & Time',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '*',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _dateController,
                                  decoration: InputDecoration(
                                    labelText: 'Date *',
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
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: _selectDate,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Date is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _timeController,
                                  decoration: InputDecoration(
                                    labelText: 'Time *',
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
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: _selectTime,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Time is required';
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
                          TextFormField(
                            controller: _capacityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Available Seats *',
                              hintText: 'Enter number of seats (1-8)',
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
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Number of seats is required';
                              }
                              final capacity = int.tryParse(value.trim());
                              if (capacity == null) {
                                return 'Please enter a valid number';
                              }
                              if (capacity < 1 || capacity > 8) {
                                return 'Seats must be between 1 and 8';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Price per seat (₹) *',
                              hintText: 'Enter price per seat',
                              prefixIcon: Icon(
                                Icons.attach_money,
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
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Price per seat is required';
                              }
                              final price = double.tryParse(value.trim());
                              if (price == null) {
                                return 'Please enter a valid price';
                              }
                              if (price < 0) {
                                return 'Price cannot be negative';
                              }
                              if (price > 10000) {
                                return 'Price seems too high';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            readOnly: _phoneController.text.isNotEmpty,
                            decoration: InputDecoration(
                              labelText: 'Contact Number *',
                              hintText: 'Enter your phone number',
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
                                      ? 'Using your registered phone number'
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
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Contact number is required';
                              }
                              final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                              if (!phoneRegex.hasMatch(value.trim())) {
                                return 'Enter a valid 10-digit phone number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Description *',
                              hintText:
                                  'Describe your ride, vehicle details, pickup points, etc. (minimum 5 characters)',
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
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              counterText:
                                  '${_descriptionController.text.length}/500',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description is required';
                              }
                              if (value.trim().length < 5) {
                                return 'Description must be at least 5 characters';
                              }
                              if (value.trim().length > 500) {
                                return 'Description must be less than 500 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Fields marked with * are required',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_isLoading || !_isFormValid) ? null : _createRide,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        backgroundColor:
                            _isFormValid ? null : Colors.grey.shade300,
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
                                  Text('Creating Ride...'),
                                ],
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    color:
                                        _isFormValid
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create Ride',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _isFormValid
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  if (!_isFormValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please fill in all required fields to create a ride',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      _validateForm();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      _validateForm();
    }
  }

  Future<void> _createRide() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('Please fill in all required fields correctly'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DateTime rideDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final rideData = {
        'from': _fromController.text.trim(),
        'to': _toController.text.trim(),
        'date': rideDateTime.toIso8601String(),
        'capacity': int.parse(_capacityController.text.trim()),
        'price':
            _priceController.text.trim().isNotEmpty
                ? double.parse(_priceController.text.trim())
                : null,
        'phoneNo': _phoneController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      final result = await RideService.createRide(rideData);

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Ride created successfully!')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        _formKey.currentState!.reset();
        _fromController.clear();
        _toController.clear();
        _dateController.clear();
        _timeController.clear();
        _capacityController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _selectedDate = null;
        _selectedTime = null;
        _loadUserPhoneNumber();
        _validateForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(result['message'] ?? 'Failed to create ride'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Flexible(child: Text('Error creating ride: $error')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
