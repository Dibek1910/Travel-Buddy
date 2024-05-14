import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/utils/RideDetailsScreen.dart';

class SearchRidePage extends StatefulWidget {
  final String authToken;

  const SearchRidePage({Key? key, required this.authToken}) : super(key: key);

  @override
  _SearchRidePageState createState() => _SearchRidePageState();
}

class _SearchRidePageState extends State<SearchRidePage> {
  String _from = '';
  String _to = '';
  String _date = '';
  List<dynamic> rides = []; // Declare rides here

  late TextEditingController
      _dateController; // Define TextEditingController for date

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(); // Initialize _dateController
  }

  @override
  void dispose() {
    _dateController.dispose(); // Dispose of _dateController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Ride'),
        automaticallyImplyLeading: false, // Remove back arrow and functionality
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField('From', (value) {
              _from = value;
            }),
            SizedBox(height: 16),
            _buildTextField('To', (value) {
              _to = value;
            }),
            SizedBox(height: 16),
            _buildDateInputBox('Date (YYYY-MM-DD)',
                _dateController), // Use _dateController for date input
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchRides,
              child: Text('Search'),
            ),
            SizedBox(height: 16),
            if (rides.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    return RideItem(
                      ride: ride,
                      authToken: widget.authToken,
                      requestRide: _requestRide,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInputBox(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.orange, // Adjust primary color
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null && pickedDate != DateTime.now()) {
          setState(() {
            _date = DateFormat('yyyy-MM-dd')
                .format(pickedDate); // Update _date with selected date
            controller.text = _date; // Update controller text
          });
        }
      },
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              labelText: label,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, ValueChanged<String> onChanged) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(12),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _searchRides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      print('AuthToken retrieved from SharedPreferences: $authToken');

      final Uri url = Uri.parse(
          'https://carpool-backend.devashish-roy.com/api/rides/search');

      final response = await http.post(
        url,
        headers: {
          'authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': _from,
          'to': _to,
          'date': _date,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final success = responseData['success'] as bool;
        if (success) {
          final allRides = responseData['rides'] as List<dynamic>;

          // Filter out rides created by the current user
          final List<dynamic> filteredRides = [];
          for (var ride in allRides) {
            if (ride['host']['_id'] != authToken) {
              filteredRides.add(ride);
            }
          }

          // Fetch ride details including host information
          final List<dynamic> updatedRides =
              await _fetchRideDetails(filteredRides);

          setState(() {
            rides = updatedRides;
          });

          if (rides.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('No rides available on this date or route.'),
              backgroundColor: Colors.red,
            ));
          } else {
            print('Rides fetched successfully.');
          }
        } else {
          print('Failed to fetch rides. Server error: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to fetch rides. Please try again later.'),
            backgroundColor: Colors.red,
          ));
        }
      } else if (response.statusCode == 500) {
        print('Server error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Server error. Please try again later.'),
          backgroundColor: Colors.red,
        ));
      } else {
        print('Failed to fetch rides. Server error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to fetch rides. Server error.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      print('Failed to fetch rides. Network error: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch rides. Network error.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<List<dynamic>> _fetchRideDetails(List<dynamic> rides) async {
    List<dynamic> updatedRides = [];
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');

    for (var ride in rides) {
      final rideId = ride['_id'];
      final rideDetailsUrl = Uri.parse(
          'https://carpool-backend.devashish-roy.com/api/rides/get/$rideId');
      final rideDetailsResponse = await http.get(
        rideDetailsUrl,
        headers: {
          'authorization': 'Bearer $authToken',
        },
      );

      if (rideDetailsResponse.statusCode == 200) {
        final rideDetailsData = jsonDecode(rideDetailsResponse.body);
        final createdBy = rideDetailsData['rideDetails']['host']['_id'];

        // Check if the ride is not created by the logged-in user
        if (createdBy != prefs.getString('userId')) {
          updatedRides.add(rideDetailsData['rideDetails']);
          print('Ride details fetched successfully for ride ID: $rideId');
        } else {
          print('Ride is created by the current user. Skipping...');
        }
      } else {
        print('Failed to fetch ride details for ride ID: $rideId');
        print('Error: ${rideDetailsResponse.body}');
        // Handle failure to fetch ride details
      }
    }

    return updatedRides;
  }

  void _requestRide(BuildContext context, dynamic ride) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      final rideId = ride['_id'];

      final Uri url = Uri.parse(
          'https://carpool-backend.devashish-roy.com/api/rides/request');

      final response = await http.post(
        url,
        headers: {
          'authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rideId': rideId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ride requested successfully.'),
          backgroundColor: Colors.green,
        ));
      } else {
        print('Failed to request ride. Server error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to request ride. Please try again later.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      print('Failed to request ride. Network error: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to request ride. Network error.'),
        backgroundColor: Colors.red,
      ));
    }
  }
}

class RideItem extends StatelessWidget {
  final dynamic ride;
  final String authToken;
  final Function(BuildContext, dynamic) requestRide;

  const RideItem(
      {Key? key,
      required this.ride,
      required this.authToken,
      required this.requestRide})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCurrentUserHost = ride['host']['_id'] == authToken;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text('From: ${ride['from']} - To: ${ride['to']}'),
        subtitle: Text('Date: ${ride['date']}'),
        trailing: isCurrentUserHost
            ? null
            : ElevatedButton(
                onPressed: () {
                  requestRide(context, ride); // Request the ride directly
                },
                child: Text('Request Ride'),
              ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideDetailsScreen(
                rideDetails: ride,
              ),
            ),
          );
        },
      ),
    );
  }
}
