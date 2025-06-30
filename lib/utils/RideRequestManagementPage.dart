import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/ride_service.dart';

class RideRequestManagementPage extends StatefulWidget {
  final String rideId;
  final Map<String, dynamic> rideDetails;

  const RideRequestManagementPage({
    Key? key,
    required this.rideId,
    required this.rideDetails,
  }) : super(key: key);

  @override
  _RideRequestManagementPageState createState() =>
      _RideRequestManagementPageState();
}

class _RideRequestManagementPageState extends State<RideRequestManagementPage> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, bool> _processingRequests = {};

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadRequests() {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Extract requests from ride details
      final requests = widget.rideDetails['requests'] ?? [];

      if (!mounted) return;

      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error loading requests: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate request statistics - Fixed: Safe filtering with proper type checking
    final pendingRequests = _requests.where((req) {
      if (req is Map<String, dynamic> && req.containsKey('status')) {
        return req['status'] == 'pending';
      }
      return false;
    }).length;

    final approvedRequests = _requests.where((req) {
      if (req is Map<String, dynamic> && req.containsKey('status')) {
        return req['status'] == 'approved';
      }
      return false;
    }).length;

    final rejectedRequests = _requests.where((req) {
      if (req is Map<String, dynamic> && req.containsKey('status')) {
        return req['status'] == 'rejected';
      }
      return false;
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Requests'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Loading requests...',
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
                        child: Text(_errorMessage,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRequests,
                        child: Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ride Info Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.directions_car,
                                        color: Colors.orange, size: 24),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${widget.rideDetails['from'] ?? 'Unknown'} → ${widget.rideDetails['to'] ?? 'Unknown'}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Request Summary
                                Text(
                                  'Request Summary',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildSummaryItem('Pending',
                                        pendingRequests, Colors.orange),
                                    _buildSummaryItem('Approved',
                                        approvedRequests, Colors.green),
                                    _buildSummaryItem('Rejected',
                                        rejectedRequests, Colors.red),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Requests List
                        Text(
                          'Passenger Requests',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (_requests.isNotEmpty)
                          Text(
                            '${_requests.length} total',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        SizedBox(height: 16),

                        if (_requests.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                SizedBox(height: 40),
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
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _requests.length,
                            itemBuilder: (context, index) {
                              final request = _requests[index];
                              // Safe access to request ID
                              final requestId = request is Map<String, dynamic>
                                  ? request['_id'] ?? 'unknown_$index'
                                  : 'unknown_$index';

                              return RequestItem(
                                request: request,
                                isProcessing:
                                    _processingRequests[requestId] ?? false,
                                onApprove: () =>
                                    _handleRequestAction(requestId, 'approved'),
                                onReject: () =>
                                    _handleRequestAction(requestId, 'rejected'),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryItem(String label, int count, MaterialColor color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color[50],
            shape: BoxShape.circle,
            border: Border.all(color: color[200]!, width: 2),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color[800],
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color[700],
          ),
        ),
      ],
    );
  }

  Future<void> _handleRequestAction(String requestId, String action) async {
    if (!mounted) return;

    setState(() {
      _processingRequests[requestId] = true;
    });

    try {
      final result = await RideService.updateRideRequestStatus(
        widget.rideId,
        requestId,
        action,
      );

      if (!mounted) return;

      if (result['success']) {
        // Update the local request status
        setState(() {
          final requestIndex = _requests.indexWhere((req) {
            if (req is Map<String, dynamic>) {
              return req['_id'] == requestId;
            }
            return false;
          });

          if (requestIndex != -1 &&
              _requests[requestIndex] is Map<String, dynamic>) {
            _requests[requestIndex]['status'] = action;
          }
          _processingRequests[requestId] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                    'Request ${action == 'approved' ? 'approved' : 'rejected'} successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _processingRequests[requestId] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update request'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _processingRequests[requestId] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating request: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class RequestItem extends StatelessWidget {
  final dynamic request;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const RequestItem({
    Key? key,
    required this.request,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safe access to request data
    if (request is! Map<String, dynamic>) {
      return Card(
        margin: EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Invalid request data',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final Map<String, dynamic> requestData = request as Map<String, dynamic>;
    final passenger = requestData['passenger'];
    final passengerName = passenger is Map<String, dynamic>
        ? passenger['firstName'] ?? 'Unknown'
        : 'Unknown';
    final status = requestData['status'] ?? 'pending';

    // Format request date
    String requestDate = '';
    if (requestData['createdAt'] != null) {
      try {
        final date = DateTime.parse(requestData['createdAt']);
        requestDate = DateFormat('MMM dd, yyyy - HH:mm').format(date);
      } catch (e) {
        requestDate = 'Unknown date';
      }
    }

    // Status styling
    MaterialColor statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passenger info and status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  radius: 25,
                  child: Text(
                    passengerName.isNotEmpty
                        ? passengerName[0].toUpperCase()
                        : 'U',
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
                        passengerName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (requestDate.isNotEmpty)
                        Text(
                          'Requested: $requestDate',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor[800]),
                      SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor[800],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action buttons for pending requests
            if (status == 'pending') ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isProcessing ? null : onApprove,
                      icon: isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.check, size: 18),
                      label: Text(isProcessing ? 'Processing...' : 'Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
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
                      onPressed: isProcessing ? null : onReject,
                      icon: isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.close, size: 18),
                      label: Text(isProcessing ? 'Processing...' : 'Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
