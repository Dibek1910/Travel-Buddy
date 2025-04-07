import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/ride_service.dart';

class UpdateRideDetailsPage extends StatefulWidget {
  final dynamic ride;
  final VoidCallback? onRideUpdated;

  const UpdateRideDetailsPage({
    Key? key,
    required this.ride,
    this.onRideUpdated,
  }) : super(key: key);

  @override
  _UpdateRideDetailsPageState createState() => _UpdateRideDetailsPageState();
}

class _UpdateRideDetailsPageState extends State<UpdateRideDetailsPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController =
      TextEditingController(); // Added time controller
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing ride details
    _fromController.text = widget.ride['from'] ?? '';
    _toController.text = widget.ride['to'] ?? '';
    _dateController.text = widget.ride['date'] ?? '';
    _timeController.text =
        widget.ride['time'] ?? ''; // Initialize time controller
    _capacityController.text = widget.ride['capacity']?.toString() ?? '';
    _priceController.text = widget.ride['price']?.toString() ?? '';
    _descriptionController.text = widget.ride['description'] ?? '';
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _timeController.dispose(); // Dispose time controller
    _capacityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Ride Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Ride Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Update the details of your ride',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (_message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _message,
                          style: TextStyle(
                            color: _message.contains('successfully')
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    _buildTextField('From', _fromController),
                    SizedBox(height: 16),
                    _buildTextField('To', _toController),
                    SizedBox(height: 16),
                    _buildDateInputField('Date', _dateController),
                    SizedBox(height: 16),
                    _buildTimeInputField(
                        'Time', _timeController), // Added time input field
                    SizedBox(height: 16),
                    _buildTextField(
                      'Capacity',
                      _capacityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Price',
                      _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Description',
                      _descriptionController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateRideDetails,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Update Ride'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildDateInputField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _selectDate(context, controller),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInputField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _selectTime(context, controller),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Icon(Icons.access_time),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _updateRideDetails() async {
    // Validate inputs
    if (_fromController.text.isEmpty ||
        _toController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _capacityController.text.isEmpty) {
      setState(() {
        _message = 'Please fill all required fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final updatedDetails = {
        'from': _fromController.text,
        'to': _toController.text,
        'date': _dateController.text,
        'time': _timeController.text, // Include time in updated details
        'capacity': int.parse(_capacityController.text),
        'price': _priceController.text.isEmpty
            ? 0
            : double.parse(_priceController.text),
        'description': _descriptionController.text,
      };

      final result = await RideService.updateRideDetails(
        widget.ride['_id'],
        updatedDetails,
      );

      setState(() {
        _isLoading = false;
        _message = result['message'];
      });

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ride updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Call the callback if provided
        if (widget.onRideUpdated != null) {
          widget.onRideUpdated!();
        }

        // Navigate back after a short delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _message = 'Error updating ride: $error';
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update ride. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
