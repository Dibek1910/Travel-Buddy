import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/utils/UpdateRideDetailsPage.dart';

class MyRidesPage extends StatefulWidget {
  final String authToken;

  const MyRidesPage({Key? key, required this.authToken}) : super(key: key);

  @override
  _MyRidesPageState createState() => _MyRidesPageState();
}

class _MyRidesPageState extends State<MyRidesPage> {
  List<dynamic> userRides = [];

  @override
  void initState() {
    super.initState();
    _fetchUserRides();
  }

  Future<void> _fetchUserRides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      print('AuthToken retrieved from SharedPreferences: $authToken');

      if (authToken == null) {
        print('Authentication token not found. User might not be logged in.');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final Uri url = Uri.parse(
          'https://carpool-backend.devashish-roy.com/api/rides/user-created');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final rides = responseData['rides'] as List<dynamic>;

        // Filter rides for current date or future dates
        final currentDate = DateTime.now();
        final filteredRides = rides.where((ride) {
          final rideDate = DateTime.parse(ride['date']);
          return rideDate.isAfter(currentDate) ||
              rideDate.isAtSameMomentAs(currentDate);
        }).toList();

        setState(() {
          userRides = filteredRides;
        });
        print('Rides fetched successfully!');
      } else if (response.statusCode == 401) {
        // Unauthorized - Token expired or invalid, navigate to login
        print('Unauthorized: Token expired or invalid.');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Handle other error codes
        print(
            'Failed to fetch user rides. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to fetch user rides. Please try again later.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      print('Failed to fetch user rides. Network error: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Network error. Please check your connection and try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Rides'),
        automaticallyImplyLeading: false,
      ),
      body: userRides.isNotEmpty
          ? ListView.builder(
              itemCount: userRides.length,
              itemBuilder: (context, index) {
                return RideItem(ride: userRides[index]);
              },
            )
          : Center(
              child: Text('No rides found'),
            ),
    );
  }
}

class RideItem extends StatelessWidget {
  final dynamic ride;

  const RideItem({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Align items horizontally
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From: ${ride['from']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text('To: ${ride['to']}'),
                  SizedBox(height: 4.0),
                  Text('Date: ${ride['date']}'),
                  SizedBox(height: 4.0),
                  Text('Capacity: ${ride['capacity']}'),
                  SizedBox(height: 4.0),
                  Text('Price: ${ride['price']}'),
                  SizedBox(height: 4.0),
                  Text('Description: ${ride['description']}'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateRideDetailsPage(ride: ride),
                  ),
                );
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
