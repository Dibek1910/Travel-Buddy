import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/Screens/user_dashboard.dart';

class UpdateRideDetailsPage extends StatefulWidget {
  final dynamic ride;

  const UpdateRideDetailsPage({Key? key, required this.ride}) : super(key: key);

  @override
  _UpdateRideDetailsPageState createState() => _UpdateRideDetailsPageState();
}

class _UpdateRideDetailsPageState extends State<UpdateRideDetailsPage> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with existing ride details
    fromController.text = widget.ride['from'];
    toController.text = widget.ride['to'];
    capacityController.text = widget.ride['capacity'].toString();
    dateController.text = widget.ride['date'];
    priceController.text = widget.ride['price'].toString();

    descriptionController.text = widget.ride['description'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Ride Details'),
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildForm(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: fromController,
            decoration: InputDecoration(labelText: 'From'),
          ),
          TextField(
            controller: toController,
            decoration: InputDecoration(labelText: 'To'),
          ),
          TextField(
            controller: capacityController,
            decoration: InputDecoration(labelText: 'Capacity'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: dateController,
            decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
          ),
          TextField(
            controller: priceController,
            decoration: InputDecoration(labelText: 'Price'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _updateRideDetails,
            child: Text('Update Ride'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRideDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final int? capacity = int.tryParse(capacityController.text);
      final double? price = double.tryParse(priceController.text);
      if (capacity == null || price == null) {
        throw Exception('Invalid input for capacity or price');
      }

      final response = await http.patch(
        Uri.parse('https://carpool-backend.devashish-roy.com/api/rides/update'),
        headers: {
          'authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rideId': widget.ride['_id'],
          'from': fromController.text,
          'to': toController.text,
          'capacity': capacity,
          'date': dateController.text,
          'price': price,
          'description': descriptionController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final success = responseData['success'] as bool;
        final message = responseData['message'] as String;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ));

          // Redirect to MyRide page after updating
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => UserDashboard(
                authToken: '',
              ), // Replace MyRidePage with the actual page name
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        throw Exception(
            'Failed to update ride. Server error ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error'); // Print the error to the terminal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update ride. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
