import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MyRequestsPage extends StatefulWidget {
  final String authToken;
  final Function(String)? updateRideStatusCallback;
  final VoidCallback onSwitchToSearchRide;

  const MyRequestsPage({
    Key? key,
    required this.authToken,
    this.updateRideStatusCallback,
    required this.onSwitchToSearchRide,
  }) : super(key: key);

  @override
  _MyRequestsPageState createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, bool> _cancellingRequests = {};

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await RideService.getUserRideRequests();

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _requests = result['requests'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load requests';
          _isLoading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error loading requests: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      String cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

      if (cleanPhoneNumber.length == 10) {
        cleanPhoneNumber = '91$cleanPhoneNumber';
      }

      final List<String> whatsappUrls = [
        'whatsapp://send?phone=$cleanPhoneNumber',
        'https://wa.me/$cleanPhoneNumber',
        'https://api.whatsapp.com/send?phone=$cleanPhoneNumber',
      ];

      bool launched = false;

      for (String url in whatsappUrls) {
        try {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            launched = true;
            break;
          }
        } catch (e) {
          continue;
        }
      }

      if (!launched) {
        final Uri phoneUri = Uri.parse('tel:+$cleanPhoneNumber');
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          throw Exception('No communication app available');
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open WhatsApp. Trying phone dialer...'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Call',
            textColor: Colors.white,
            onPressed: () async {
              try {
                String cleanPhoneNumber = phoneNumber.replaceAll(
                  RegExp(r'\D'),
                  '',
                );
                if (cleanPhoneNumber.length == 10) {
                  cleanPhoneNumber = '91$cleanPhoneNumber';
                }
                final Uri phoneUri = Uri.parse('tel:+$cleanPhoneNumber');
                await launchUrl(phoneUri);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Requests'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadRequests),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Loading your requests...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : _errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
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
                      onPressed: _loadRequests,
                      child: Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              )
              : _requests.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No ride requests yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Search for rides and send requests to join',
                        style: TextStyle(color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: widget.onSwitchToSearchRide,
                      icon: Icon(Icons.search),
                      label: Text('Search Rides'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadRequests,
                color: Colors.orange,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    return RequestItem(
                      request: _requests[index],
                      isCancelling:
                          _cancellingRequests[_requests[index]['_id']] ?? false,
                      onCancel: () => _cancelRequest(_requests[index]['_id']),
                      onOpenWhatsApp: _openWhatsApp,
                    );
                  },
                ),
              ),
    );
  }

  Future<void> _cancelRequest(String requestId) async {
    if (!mounted) return;

    setState(() {
      _cancellingRequests[requestId] = true;
    });

    try {
      final result = await RideService.cancelRideRequest(requestId);

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _requests.removeWhere((req) => req['_id'] == requestId);
          _cancellingRequests.remove(requestId);
        });

        if (widget.updateRideStatusCallback != null) {
          widget.updateRideStatusCallback!('cancelled');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Request cancelled successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _cancellingRequests[requestId] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to cancel request'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _cancellingRequests[requestId] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling request: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class RequestItem extends StatelessWidget {
  final dynamic request;
  final bool isCancelling;
  final VoidCallback onCancel;
  final Function(String) onOpenWhatsApp;

  const RequestItem({
    Key? key,
    required this.request,
    required this.isCancelling,
    required this.onCancel,
    required this.onOpenWhatsApp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ride = request['ride'];
    final status = request['status'] ?? 'pending';

    String formattedDate = '';
    if (ride != null && ride['date'] != null) {
      try {
        final date = DateTime.parse(ride['date']);
        formattedDate = DateFormat('MMM dd, yyyy - HH:mm').format(date);
      } catch (e) {
        formattedDate = ride['date'].toString();
      }
    }

    Color statusColor;
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

    String? hostPhoneNumber;
    if (ride != null &&
        ride['host'] != null &&
        ride['host']['phoneNo'] != null) {
      hostPhoneNumber = ride['host']['phoneNo'].toString();
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.route,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your Journey',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
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
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FROM',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                ride['from'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 8, bottom: 8),
                      child: Container(
                        width: 2,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                ride['to'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

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
                        Icon(Icons.schedule, color: Colors.blue[600], size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ride['host'] != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.orange[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Host: ${ride['host']['firstName'] ?? 'Unknown'}',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              if (ride['price'] != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: Colors.green[600],
                        size: 18,
                      ),
                      Text(
                        '₹${ride['price']} per seat',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 16),

              if (status == 'approved' && hostPhoneNumber != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onOpenWhatsApp(hostPhoneNumber!),
                        icon: Icon(Icons.chat, size: 18),
                        label: Text('Contact Host'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isCancelling ? null : onCancel,
                        icon:
                            isCancelling
                                ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Icon(Icons.cancel, size: 18),
                        label: Text(isCancelling ? 'Cancelling...' : 'Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (status == 'pending') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isCancelling ? null : onCancel,
                    icon:
                        isCancelling
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Icon(Icons.cancel, size: 18),
                    label: Text(
                      isCancelling ? 'Cancelling...' : 'Cancel Request',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ] else if (status == 'rejected') ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.red[600],
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Request was rejected by host',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
