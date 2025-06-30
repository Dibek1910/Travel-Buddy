import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/ride_service.dart';

class RideRequestManagementPage extends StatefulWidget {
  final dynamic rideDetails;
  final VoidCallback onRequestUpdated;

  const RideRequestManagementPage({
    Key? key,
    required this.rideDetails,
    required this.onRequestUpdated,
  }) : super(key: key);

  @override
  _RideRequestManagementPageState createState() =>
      _RideRequestManagementPageState();
}

class _RideRequestManagementPageState extends State<RideRequestManagementPage> {
  late dynamic rideDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    rideDetails = widget.rideDetails;
  }

  @override
  Widget build(BuildContext context) {
    final List requests = rideDetails['requests'] ?? [];
    final int capacity = rideDetails['capacity'] ?? 0;
    final int approvedRequests =
        requests.where((req) => req['status'] == 'approved').length;
    final int availableSeats = capacity - approvedRequests;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Requests'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No requests yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Requests will appear here when passengers request to join your ride',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Ride summary card
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${rideDetails['from']} → ${rideDetails['to']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.event_seat,
                                  size: 16, color: Colors.orange[700]),
                              SizedBox(width: 4),
                              Text(
                                'Available seats: $availableSeats/$capacity',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Requests list
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          return RequestManagementItem(
                            request: requests[index],
                            availableSeats: availableSeats,
                            onStatusUpdate: _updateRequestStatus,
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RideService.updateRequestStatus(requestId, status);

      if (result['success']) {
        // Refresh ride details
        final updatedRide = await RideService.getRideById(rideDetails['_id']);
        if (updatedRide['success']) {
          setState(() {
            rideDetails = updatedRide['rideDetails'];
            _isLoading = false;
          });

          widget.onRequestUpdated();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Request ${status} successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });

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
              Text('Error updating request: $error'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class RequestManagementItem extends StatelessWidget {
  final dynamic request;
  final int availableSeats;
  final Function(String, String) onStatusUpdate;

  const RequestManagementItem({
    Key? key,
    required this.request,
    required this.availableSeats,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = request['status'] ?? 'pending';
    final passenger = request['passenger'];

    // Format date
    String formattedDate = '';
    if (request['createdAt'] != null) {
      try {
        final date = DateTime.parse(request['createdAt']);
        formattedDate = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        formattedDate = request['createdAt'];
      }
    }

    // Status color and text
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'APPROVED';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'REJECTED';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'PENDING';
        statusIcon = Icons.schedule;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with passenger info and status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  radius: 25,
                  child: Text(
                    passenger['firstName'][0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passenger['firstName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Requested on $formattedDate',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action buttons for pending requests
            if (status.toLowerCase() == 'pending') ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: availableSeats > 0
                          ? () => _showConfirmationDialog(
                                context,
                                'Approve Request',
                                'Are you sure you want to approve this request?',
                                () =>
                                    onStatusUpdate(request['_id'], 'approved'),
                              )
                          : null,
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            availableSeats > 0 ? Colors.green : Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showConfirmationDialog(
                        context,
                        'Reject Request',
                        'Are you sure you want to reject this request?',
                        () => onStatusUpdate(request['_id'], 'rejected'),
                      ),
                      icon: Icon(Icons.close, size: 18),
                      label: Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (availableSeats <= 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'No available seats to approve more requests',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    title.contains('Approve') ? Colors.green : Colors.red,
              ),
              child: Text(title.contains('Approve') ? 'Approve' : 'Reject'),
            ),
          ],
        );
      },
    );
  }
}
