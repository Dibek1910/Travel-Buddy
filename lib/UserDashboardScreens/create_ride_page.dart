import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateRidePage extends StatefulWidget {
  final String authToken;

  const CreateRidePage({Key? key, required this.authToken}) : super(key: key);

  @override
  _CreateRidePageState createState() => _CreateRidePageState();
}

class _CreateRidePageState extends State<CreateRidePage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Ride'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputBox('From', _fromController),
              _buildInputBox('To', _toController),
              _buildDateInputBox('Date', _dateController),
              _buildInputBox('Capacity', _capacityController,
                  keyboardType: TextInputType.number),
              _buildInputBox('Price', _priceController,
                  keyboardType: TextInputType.number),
              _buildInputBox('Description', _descriptionController),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _createRide,
                child: Text('Create Ride'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      int? maxLength,
      bool obscureText = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ]
            : null,
        maxLength: maxLength,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
        ),
      ),
    );
  }

  Widget _buildDateInputBox(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _selectDate(context, controller),
      child: AbsorbPointer(
        child: _buildInputBox(label, controller),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Only allow future dates
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _createRide() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      print('AuthToken retrieved from SharedPreferences: $authToken');

      if (authToken == null) {
        print('Authentication token not found. User might not be logged in.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Authentication token not found. Please log in.'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      final Map<String, dynamic> requestData = {
        "from": _fromController.text,
        "to": _toController.text,
        "date": _dateController.text,
        "capacity": int.tryParse(_capacityController.text) ?? 0,
        "price": _priceController.text,
        "description": _descriptionController.text,
      };

      final Uri url = Uri.parse(
          'https://carpool-backend.devashish-roy.com/api/rides/create');

      final response = await http.post(
        url,
        headers: {
          'authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final success = responseData['success'] as bool;
        final message = responseData['message'] as String;
        if (success) {
          // Ride created successfully
          print('Ride created successfully: $message');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ride created successfully: $message'),
            backgroundColor: Colors.green,
          ));
        } else {
          // Ride creation failed
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to create ride: $message'),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        // Server error
        print('Failed to create ride. Server error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create ride. Please try again later.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      // Network error
      print('Failed to create ride. Network error: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Network error. Please check your connection and try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
