import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:travel_buddy/services/auth_service.dart';

class RideDetailsScreen extends StatefulWidget {
  final dynamic rideDetails;

  const RideDetailsScreen({Key? key, required this.rideDetails})
    : super(key: key);

  @override
  _RideDetailsScreenState createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentUserId() async {
    try {
      final userId = await AuthService.getCurrentUserId();
      if (mounted) {
        setState(() {
          _currentUserId = userId;
        });
      }
    } catch (e) {
      print('Error getting current user ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.rideDetails;

    final int capacity = ride['capacity'] ?? 0;
    final List requests = ride['requests'] ?? [];

    final int approvedRequests =
        requests.where((req) {
          if (req is Map<String, dynamic> &&
              req.containsKey('status') &&
              req['status'] is String) {
            return req['status'] == 'approved';
          }
          return false;
        }).length;

    final int pendingRequests =
        requests.where((req) {
          if (req is Map<String, dynamic> &&
              req.containsKey('status') &&
              req['status'] is String) {
            return req['status'] == 'pending';
          }
          return false;
        }).length;

    final int availableSeats = capacity - approvedRequests;
    final bool isFull = availableSeats <= 0;

    String formattedDateTime = '';
    if (ride['date'] != null) {
      try {
        final date = DateTime.parse(ride['date']);
        formattedDateTime = DateFormat(
          'EEEE, MMM dd, yyyy - HH:mm',
        ).format(date);
      } catch (e) {
        formattedDateTime = ride['date'].toString();
      }
    }

    final host = ride['host'];
    final hostName =
        host != null ? '${host['firstName'] ?? ''}'.trim() : 'Unknown Host';

    final hostId = host != null ? host['_id'] : null;
    final isCurrentUserHost =
        _currentUserId != null && hostId == _currentUserId;

    final hasUserRequested = requests.any((req) {
      if (req is Map<String, dynamic> &&
          req['passenger'] is Map<String, dynamic>) {
        final passengerId = req['passenger']['_id'];
        return passengerId == _currentUserId;
      }
      return false;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.orange,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${ride['from']} → ${ride['to']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
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
                                color:
                                    isFull
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
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                formattedDateTime,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange[100],
                              radius: 25,
                              child: Text(
                                hostName.isNotEmpty
                                    ? hostName[0].toUpperCase()
                                    : 'H',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCurrentUserHost
                                        ? 'Your Ride'
                                        : 'Hosted by',
                                    style: TextStyle(
                                      color: Colors.orange[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    hostName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                        'Ride Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.people,
                        'Total Capacity',
                        '${ride['capacity']} passengers',
                      ),
                      _buildDetailRow(
                        Icons.people_outline,
                        'Available Seats',
                        '$availableSeats seats',
                      ),
                      if (ride['price'] != null)
                        _buildDetailRow(
                          Icons.attach_money,
                          'Price per seat',
                          '₹${ride['price']}',
                        ),
                      if (ride['phoneNo'] != null)
                        _buildDetailRow(
                          Icons.phone,
                          'Contact',
                          '${ride['phoneNo']}',
                        ),
                      if (ride['description'] != null &&
                          ride['description'].toString().isNotEmpty) ...[
                        SizedBox(height: 12),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ride['description'].toString(),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (requests.isNotEmpty) ...[
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
                          'Request Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Total Requests: ${requests.length}',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatusChip(
                              'Pending',
                              pendingRequests,
                              Colors.orange,
                            ),
                            SizedBox(width: 8),
                            _buildStatusChip(
                              'Approved',
                              approvedRequests,
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24),
              if (!isCurrentUserHost) ...[
                if (hasUserRequested) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.blue[600]),
                        SizedBox(width: 8),
                        Text(
                          'Request Already Sent',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (!isFull) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading
                              ? null
                              : () => _requestToJoinRide(ride['_id']),
                      icon:
                          _isLoading
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(Icons.send),
                      label: Text(
                        _isLoading ? 'Sending Request...' : 'Request to Join',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.block, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Ride is Full',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.orange[600]),
                      SizedBox(width: 8),
                      Text(
                        'This is Your Ride',
                        style: TextStyle(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
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
            child: Text(value, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, MaterialColor color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color[200]!),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color[800],
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _requestToJoinRide(String rideId) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RideService.requestRide(rideId);

      if (!mounted) return;

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

        Navigator.of(context).pop();
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
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Flexible(child: Text('Error sending request: $error')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
