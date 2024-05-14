import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Logout'),
      content: Text('Do you want to logout?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            _logout(context);
          },
          child: Text('Yes'),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      print('AuthToken retrieved from SharedPreferences: $authToken');

      if (authToken == null) {
        print('Authentication token not found. User might not be logged in.');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('https://carpool-backend.devashish-roy.com/api/auth/logout'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print('Logout Response Code: ${response.statusCode}');
      print('Logout Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final success = responseData['success'] as bool;
        final message = responseData['message'] as String;

        if (success) {
          await prefs.remove('authToken');
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          print('Logout failed: $message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Logout failed. ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error during logout: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error during logout. Please check your connection and try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
