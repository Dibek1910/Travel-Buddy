import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:travel_buddy/utils/UpdateRideDetailsPage.dart';
import 'package:travel_buddy/utils/RideDetailsScreen.dart';
import 'package:travel_buddy/utils/RideRequestManagementPage.dart';

class MyRidesPage extends StatefulWidget {
  final String authToken;
  final VoidCallback? onSwitchToCreateRide;

  const MyRidesPage({
    Key? key,
    required this.authToken,
    this.onSwitchToCreateRide,
  }) : super(key: key);

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
          try {
            final rideDate = DateTime.parse(ride['date']);
            return rideDate.isAfter(currentDate.subtract(Duration(days: 1)));
          } catch (e) {
            return true; // Include rides with invalid dates
          }
        }).toList();

        setState(() {
          userRides = filteredRides;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to fetch rides';
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
        color: Colors.orange,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.orange),
                    SizedBox(height: 16),
                    Text('Loading your rides...',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 80, color: Colors.red[300]),
                        SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchUserRides,
                          child: Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : userRides.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No rides found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create a new ride to get started',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: widget.onSwitchToCreateRide,
                              icon: Icon(Icons.add),
                              label: Text('Create Your First Ride'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: userRides.length,
                        itemBuilder: (context, index) {
                          return RideItem(
                            ride: userRides[index],
                            onRideUpdated: _fetchUserRides,
                            onRideCancelled: _cancelRide,
                          );
                        },
                      ),
      ),
    );
  }

  Future<void> _cancelRide(String rideId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Ride'),
          content: Text(
              'Are you sure you want to cancel this ride? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final result = await RideService.cancelRide(rideId);

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Ride cancelled successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _fetchUserRides(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(child: Text(result['message'])),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Flexible(child: Text('Error cancelling ride: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class RideItem extends StatelessWidget {
  final dynamic ride;
  final VoidCallback onRideUpdated;
  final Function(String) onRideCancelled;

  const RideItem({
    Key? key,
    required this.ride,
    required this.onRideUpdated,
    required this.onRideCancelled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate capacity information
    final int capacity = ride['capacity'] ?? 0;
    final List requests = ride['requests'] ?? [];
    final int approvedRequests =
        requests.where((req) => req['status'] == 'approved').length;
    final int pendingRequests =
        requests.where((req) => req['status'] == 'pending').length;
    final int availableSeats = capacity - approvedRequests;
    final bool isFull = availableSeats <= 0;

    // Format date and time
    String formattedDateTime = '';
    if (ride['date'] != null) {
      try {
        final date = DateTime.parse(ride['date']);
        formattedDateTime = DateFormat('MMM dd, yyyy - HH:mm').format(date);
      } catch (e) {
        formattedDateTime = ride['date'];
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with route and status
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orange, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${ride['from']} → ${ride['to']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Show capacity status badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFull ? Colors.red[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFull ? Colors.red : Colors.green,
                      ),
                    ),
                    child: Text(
                      isFull ? 'FULL' : '$availableSeats SEATS',
                      style: TextStyle(
                        color: isFull ? Colors.red[800] : Colors.green[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Date and basic info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                              Icons.calendar_today, formattedDateTime),
                        ),
                        Expanded(
                          child: _buildInfoRow(
                              Icons.people, 'Capacity: ${ride['capacity']}'),
                        ),
                      ],
                    ),
                    if (ride['price'] != null) ...[
                      SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.attach_money, 'Price: ₹${ride['price']}'),
                    ],
                  ],
                ),
              ),

              if (ride['description'] != null &&
                  ride['description'].isNotEmpty) ...[
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ride['description'],
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              // Request status summary
              if (requests.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people_outline,
                          color: Colors.orange[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Requests: $pendingRequests pending, $approvedRequests approved',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (pendingRequests > 0)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$pendingRequests',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 16),

              // Action buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (requests.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RideRequestManagementPage(
                                rideDetails: ride,
                                onRequestUpdated: onRideUpdated,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.people, size: 18),
                        label: Text('Manage'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    if (requests.isNotEmpty) SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateRideDetailsPage(
                              rideDetails: ride,
                              onRideUpdated: onRideUpdated,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => onRideCancelled(ride['_id']),
                      icon: Icon(Icons.cancel, size: 18),
                      label: Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
