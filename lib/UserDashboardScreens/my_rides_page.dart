import 'package:flutter/material.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:travel_buddy/utils/UpdateRideDetailsPage.dart';

class MyRidesPage extends StatefulWidget {
  final String authToken;

  const MyRidesPage({Key? key, required this.authToken}) : super(key: key);

  @override
  _MyRidesPageState createState() => _MyRidesPageState();
}

class _MyRidesPageState extends State<MyRidesPage> {
  List<dynamic> userRides = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserRides();
  }

  Future<void> _fetchUserRides() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await RideService.getUserCreatedRides();

      if (result['success']) {
        // Filter rides for current date or future dates
        final currentDate = DateTime.now();
        final rides = result['rides'] as List<dynamic>;

        final filteredRides = rides.where((ride) {
          final rideDate = DateTime.parse(ride['date']);
          return rideDate.isAfter(currentDate) ||
              rideDate.day == currentDate.day &&
                  rideDate.month == currentDate.month &&
                  rideDate.year == currentDate.year;
        }).toList();

        setState(() {
          userRides = filteredRides;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching rides: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchUserRides,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : userRides.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No rides found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create a new ride to get started',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: userRides.length,
                        itemBuilder: (context, index) {
                          return RideItem(
                            ride: userRides[index],
                            onRideUpdated: _fetchUserRides,
                          );
                        },
                      ),
      ),
    );
  }
}

class RideItem extends StatelessWidget {
  final dynamic ride;
  final VoidCallback onRideUpdated;

  const RideItem({
    Key? key,
    required this.ride,
    required this.onRideUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
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
                Icon(Icons.location_on, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${ride['from']} → ${ride['to']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                          Icons.calendar_today, 'Date: ${ride['date']}'),
                      SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.people, 'Capacity: ${ride['capacity']}'),
                      SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.attach_money, 'Price: ${ride['price']}'),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateRideDetailsPage(
                              ride: ride,
                              onRideUpdated: onRideUpdated,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (ride['requests'] != null && ride['requests'].length > 0)
                      Text(
                        '${ride['requests'].length} requests',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (ride['description'] != null && ride['description'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    _buildInfoRow(Icons.description, 'Description:'),
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Text(ride['description']),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
