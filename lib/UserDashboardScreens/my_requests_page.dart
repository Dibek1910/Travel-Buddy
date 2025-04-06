import 'package:flutter/material.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:travel_buddy/utils/RideDetailsScreen.dart';

class MyRequestsPage extends StatefulWidget {
  final String authToken;
  final Function(String) updateRideStatusCallback;

  const MyRequestsPage({
    Key? key,
    required this.authToken,
    required this.updateRideStatusCallback,
  }) : super(key: key);

  @override
  _MyRequestsPageState createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  List<dynamic> _requestedRides = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserRequests();
  }

  Future<void> _fetchUserRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await RideService.getUserRideRequests();

      if (result['success']) {
        setState(() {
          _requestedRides = result['requests'] ?? [];
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
        _errorMessage = 'Error fetching requests: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchUserRequests,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : _buildRequestsList(),
      ),
    );
  }

  Widget _buildRequestsList() {
    // Filter for current and future rides
    final currentDate = DateTime.now();
    final futureRequests = _requestedRides.where((request) {
      if (request == null ||
          request['ride'] == null ||
          request['ride']['date'] == null) {
        return false;
      }

      final rideDate = DateTime.parse(request['ride']['date']);
      return rideDate.isAfter(currentDate) ||
          (rideDate.day == currentDate.day &&
              rideDate.month == currentDate.month &&
              rideDate.year == currentDate.year);
    }).toList();

    if (futureRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.request_page_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No ride requests found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Search for rides to make requests',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: futureRequests.length,
      itemBuilder: (context, index) {
        final request = futureRequests[index];
        return RequestItem(
          request: request,
          onCancelRequest: _cancelRequest,
          onViewDetails: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RideDetailsScreen(
                  rideDetails: request['ride'],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _cancelRequest(String requestId) async {
    try {
      final result = await RideService.cancelRequest(requestId);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the list
        _fetchUserRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling request: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class RequestItem extends StatelessWidget {
  final dynamic request;
  final Function(String) onCancelRequest;
  final VoidCallback onViewDetails;

  const RequestItem({
    Key? key,
    required this.request,
    required this.onCancelRequest,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = request['status'] ?? 'pending';

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
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
                      '${request['ride']['from']} → ${request['ride']['to']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
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
              Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.calendar_today,
                            'Date: ${request['ride']['date']}'),
                        SizedBox(height: 8),
                        _buildInfoRow(Icons.person,
                            'Host: ${request['ride']['host']['firstName']} ${request['ride']['host']['lastName']}'),
                      ],
                    ),
                  ),
                  if (status == 'pending')
                    ElevatedButton.icon(
                      onPressed: () => onCancelRequest(request['_id']),
                      icon: Icon(Icons.cancel),
                      label: Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                ],
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
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
