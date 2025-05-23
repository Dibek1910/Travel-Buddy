import 'package:flutter/material.dart';
import 'package:travel_buddy/services/request_service.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RideDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> rideDetails;

  const RideDetailsScreen({Key? key, required this.rideDetails})
      : super(key: key);

  @override
  _RideDetailsScreenState createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  bool _isLoading = false;
  List<dynamic> _requests = [];
  String _errorMessage = '';
  bool _isCurrentUserHost = false;
  int _approvedRequests = 0;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsHost();
    _countApprovedRequests();
  }

  Future<void> _checkIfUserIsHost() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null && widget.rideDetails['host'] != null) {
      final isHost = widget.rideDetails['host']['_id'] == userId;

      setState(() {
        _isCurrentUserHost = isHost;
      });

      if (isHost) {
        _fetchRideRequests();
      }
    }
  }

  Future<void> _countApprovedRequests() async {
    // If the ride already has the count from the backend, use it
    if (widget.rideDetails['approvedRequests'] != null) {
      setState(() {
        _approvedRequests = widget.rideDetails['approvedRequests'];
      });
      return;
    }

    // Otherwise, count from the requests if available
    if (widget.rideDetails['requests'] != null) {
      final approvedCount = (widget.rideDetails['requests'] as List)
          .where((request) => request['status'] == 'approved')
          .length;

      setState(() {
        _approvedRequests = approvedCount;
      });
    }
  }

  Future<void> _fetchRideRequests() async {
    if (!_isCurrentUserHost) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result =
          await RequestService.getRideRequests(widget.rideDetails['_id']);

      setState(() {
        _isLoading = false;
        if (result['success']) {
          _requests = result['requests'] ?? [];

          // Count approved requests
          _approvedRequests =
              _requests.where((req) => req['status'] == 'approved').length;
        } else {
          _errorMessage = result['message'];
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching requests: $error';
      });
    }
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RideService.updateRequestStatus(requestId, status);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${status.toLowerCase()} successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the requests
        _fetchRideRequests();
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating request: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate available seats
    final int capacity = widget.rideDetails['capacity'] ?? 0;
    final int availableSeats = capacity - _approvedRequests;
    final bool isFull = availableSeats <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
        actions: [
          if (_isCurrentUserHost)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _fetchRideRequests,
              tooltip: 'Refresh requests',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed Row widget to prevent overflow
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.rideDetails['host']['firstName'][0] +
                                  widget.rideDetails['host']['lastName'][0],
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        // Use Expanded to make the text content adapt to available space
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Host: ${widget.rideDetails['host']['firstName']} ${widget.rideDetails['host']['lastName']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Email: ${widget.rideDetails['host']['email']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.rideDetails['host']['phoneNumber'] !=
                                  null)
                                Text(
                                  'Phone: ${widget.rideDetails['host']['phoneNumber']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    _buildDetailRow('From', widget.rideDetails['from']),
                    _buildDetailRow('To', widget.rideDetails['to']),
                    _buildDetailRow('Date', widget.rideDetails['date']),
                    if (widget.rideDetails['time'] != null &&
                        widget.rideDetails['time'].toString().isNotEmpty)
                      _buildDetailRow('Time', widget.rideDetails['time']),
                    _buildDetailRow(
                        'Capacity', widget.rideDetails['capacity'].toString()),
                    _buildDetailRow(
                        'Available Seats', availableSeats.toString()),
                    _buildDetailRow(
                        'Price', widget.rideDetails['price'].toString()),
                    if (widget.rideDetails['description'] != null &&
                        widget.rideDetails['description'].toString().isNotEmpty)
                      _buildDetailRow(
                          'Description', widget.rideDetails['description']),

                    // Show capacity status
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isFull ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isFull ? Colors.red[300]! : Colors.green[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isFull
                                ? Icons.error_outline
                                : Icons.check_circle_outline,
                            color: isFull ? Colors.red[700] : Colors.green[700],
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isFull
                                  ? 'This ride is full'
                                  : 'This ride has $availableSeats available seats',
                              style: TextStyle(
                                color: isFull
                                    ? Colors.red[700]
                                    : Colors.green[700],
                                fontWeight: FontWeight.bold,
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
            SizedBox(height: 16),
            if (_isCurrentUserHost) _buildRequestsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsSection() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text(_errorMessage)),
        ),
      );
    }

    // Calculate if the ride is full
    final int capacity = widget.rideDetails['capacity'] ?? 0;
    final bool isFull = _approvedRequests >= capacity;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ride Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFull ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFull ? 'FULL' : 'AVAILABLE',
                    style: TextStyle(
                      color: isFull ? Colors.red[800] : Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Approved: $_approvedRequests / $capacity seats',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            _requests.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No requests for this ride yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      final passenger = request['passenger'];
                      final status = request['status'];

                      Color statusColor;
                      switch (status) {
                        case 'approved':
                          statusColor = Colors.green;
                          break;
                        case 'rejected':
                          statusColor = Colors.red;
                          break;
                        default:
                          statusColor = Colors.orange;
                      }

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: Text(
                              passenger['firstName'][0] +
                                  passenger['lastName'][0],
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          title: Text(
                              '${passenger['firstName']} ${passenger['lastName']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(passenger['email']),
                              if (passenger['phoneNumber'] != null &&
                                  passenger['phoneNumber']
                                      .toString()
                                      .isNotEmpty)
                                Text('Phone: ${passenger['phoneNumber']}'),
                            ],
                          ),
                          trailing: status == 'pending'
                              ? ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 100),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.check,
                                            color: isFull
                                                ? Colors.grey
                                                : Colors.green),
                                        onPressed: isFull
                                            ? null
                                            : () => _updateRequestStatus(
                                                request['_id'], 'approved'),
                                        tooltip:
                                            isFull ? 'Ride is full' : 'Approve',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () => _updateRequestStatus(
                                            request['_id'], 'rejected'),
                                        tooltip: 'Reject',
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusColor),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
