import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({Key? key, required String authToken})
      : super(key: key);

  @override
  _RideHistoryPageState createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage> {
  late Future<Map<String, dynamic>> _rideHistoryFuture;

  @override
  void initState() {
    super.initState();
    _rideHistoryFuture = fetchRideHistory();
  }

  Future<Map<String, dynamic>> fetchRideHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      print('AuthToken retrieved from SharedPreferences: $authToken');

      if (authToken == null) {
        throw Exception('Authentication token not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse(
          'https://carpool-backend.devashish-roy.com/api/rides/user-ride-history',
        ),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load ride history: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching ride history: $error');
      throw Exception('Failed to load ride history: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
      ),
      body: FutureBuilder(
        future: _rideHistoryFuture,
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final success = snapshot.data!['success'] as bool;
            final message = snapshot.data!['message'] as String;
            if (success) {
              final rides = snapshot.data!['rides'] as Map<String, dynamic>;
              return ListView.builder(
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  return ListTile(
                    title: Text('From: ${ride['from']}'),
                    subtitle: Text('To: ${ride['to']}'),
                    trailing: Text('Date: ${ride['date']}'),
                  );
                },
              );
            } else {
              return Center(child: Text(message));
            }
          }
        },
      ),
    );
  }
}
