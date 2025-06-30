import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/ride_service.dart';

class RideDetailsScreen extends StatefulWidget {
  final dynamic rideDetails;

  const RideDetailsScreen({Key? key, required this.rideDetails})
      : super(key: key);

  @override
  _RideDetailsScreenState createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  bool _isLoading = false;
  late dynamic rideDetails;

  @override
  void initState() {
    super.initState();
    rideDetails = widget.rideDetails;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate capacity information
    final int capacity = rideDetails['capacity'] ?? 0;
    final List requests = rideDetails['requests'] ?? [];
    final int approvedRequests =
        requests.where((req) => req['status'] == 'approved').length;
    final int availableSeats = capacity - approvedRequests;
    final bool isFull = availableSeats <= 0;

    // Format date
    String formattedDate = '';
    if (rideDetails['date'] != null) {
      try {
        final date = DateTime.parse(rideDetails['date']);
        formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(date);
      } catch (e) {
        formattedDate = rideDetails['date'];
      }
    }

    // Host information
    final host = rideDetails['host'];
    final hostName = host != null ? host['firstName'] ?? 'Unknown' : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main ride info card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.orange, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${rideDetails['from']} → ${rideDetails['to']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          // Availability badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  isFull ? Colors.red[100] : Colors.green[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isFull ? Colors.red : Colors.green,
                              ),
                            ),
                            child: Text(
                              isFull ? 'FULL' : '$availableSeats SEATS',
                              style: TextStyle(
                                color: isFull
                                    ? Colors.red[800]
                                    : Colors.green[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Date
                      _buildDetailRow(
                          Icons.calendar_today, 'Date', formattedDate),
                      SizedBox(height: 12),

                      // Capacity
                      _buildDetailRow(
                          Icons.people, 'Capacity', '$capacity passengers'),
                      SizedBox(height: 12),

                      // Price (if available)
                      if (rideDetails['price'] != null)
                        _buildDetailRow(Icons.currency_rupee, 'Price per seat',
                            '₹${rideDetails['price']}'),
                      if (rideDetails['price'] != null) SizedBox(height: 12),

                      // Phone number
                      if (rideDetails['phoneNo'] != null)
                        _buildDetailRow(Icons.phone, 'Contact',
                            '${rideDetails['phoneNo']}'),
                      if (rideDetails['phoneNo'] != null) SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Host information card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Host Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange[100],
                            radius: 30,
                            child: Text(
                              hostName[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hostName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (host != null && host['email'] != null)
                                  Text(
                                    host['email'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Description (if available)
              if (rideDetails['description'] != null &&
                  rideDetails['description'].isNotEmpty) ...[
                SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          rideDetails['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 24),

              // Request ride button
              if (!isFull)
                ElevatedButton(
                  onPressed: _isLoading ? null : _requestRide,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Sending Request...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send),
                            SizedBox(width: 8),
                            Text(
                              'Request to Join',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.block, color: Colors.red[700]),
                      SizedBox(width: 8),
                      Text(
                        'This ride is full',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _requestRide() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RideService.requestRide(rideDetails['_id']);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text(result['message'])),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back
        Navigator.pop(context);
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
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text('Error requesting ride: $error'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
