import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateRideStatusPage extends StatefulWidget {
  final String requestId;
  final Function(String) updateRideStatusCallback;

  const UpdateRideStatusPage({
    Key? key,
    required this.requestId,
    required this.updateRideStatusCallback,
  }) : super(key: key);

  @override
  _UpdateRideStatusPageState createState() => _UpdateRideStatusPageState();
}

class _UpdateRideStatusPageState extends State<UpdateRideStatusPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Ride Status'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  _updateRideStatus("some_status"); // Pass a status here
                },
                child: Text('Update Ride Status'),
              ),
            ),
    );
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _updateRideStatus(String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse(
            'https://carpool-backend.devashish-roy.com/api/rides/update-status'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requestId': widget.requestId,
          'status': status,
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

          // Notify the parent widget about the updated status
          widget.updateRideStatusCallback(status);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        throw Exception(
          'Failed to update ride status. Server error ${response.statusCode}',
        );
      }
    } catch (error) {
      print(
          'Error updating ride status: $error'); // Print the error to the terminal
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update ride status. Please try again.'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
