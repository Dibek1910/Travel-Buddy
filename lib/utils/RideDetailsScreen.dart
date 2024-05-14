import 'package:flutter/material.dart';

class RideDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> rideDetails;

  const RideDetailsScreen({Key? key, required this.rideDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Created by: ${rideDetails['host']['firstName']} ${rideDetails['host']['lastName']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Total Capacity: ${rideDetails['capacity']}'),
            SizedBox(height: 8),
            Text('Price: ${rideDetails['price']}'),
            SizedBox(height: 8),
            Text('Description: ${rideDetails['description']}'),
            SizedBox(height: 8),
            Text('Date: ${rideDetails['date']}'),
            SizedBox(height: 8),
            Text('From: ${rideDetails['from']}'),
            SizedBox(height: 8),
            Text('To: ${rideDetails['to']}'),
          ],
        ),
      ),
    );
  }
}
