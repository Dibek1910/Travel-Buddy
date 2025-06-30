import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/ride_service.dart';
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

class _MyRidesPageState extends State<MyRidesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _createdRides = [];
  List<dynamic> _requestedRides = [];
  bool _isLoadingCreated = true;
  bool _isLoadingRequested = true;
  String _errorMessageCreated = '';
  String _errorMessageRequested = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCreatedRides();
    _loadRequestedRides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCreatedRides() async {
    if (!mounted) return;

    setState(() {
      _isLoadingCreated = true;
      _errorMessageCreated = '';
    });

    try {
      final result = await RideService.getUserCreatedRides();

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _createdRides = result['rides'] ?? [];
          _isLoadingCreated = false;
        });
      } else {
        setState(() {
          _errorMessageCreated = result['message'] ?? 'Failed to load rides';
          _isLoadingCreated = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessageCreated = 'Error loading rides: $error';
        _isLoadingCreated = false;
      });
    }
  }

  Future<void> _loadRequestedRides() async {
    if (!mounted) return;

    setState(() {
      _isLoadingRequested = true;
      _errorMessageRequested = '';
    });

    try {
      final result = await RideService.getUserRideRequests();

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _requestedRides = result['requests'] ?? [];
          _isLoadingRequested = false;
        });
      } else {
        setState(() {
          _errorMessageRequested =
              result['message'] ?? 'Failed to load requests';
          _isLoadingRequested = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessageRequested = 'Error loading requests: $error';
        _isLoadingRequested = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Rides'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.directions_car),
              text: 'Created Rides',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'My Requests',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadCreatedRides();
              _loadRequestedRides();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Created Rides Tab
          _buildCreatedRidesTab(),
          // Requested Rides Tab
          _buildRequestedRidesTab(),
        ],
      ),
    );
  }

  Widget _buildCreatedRidesTab() {
    if (_isLoadingCreated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('Loading your rides...',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (_errorMessageCreated.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(_errorMessageCreated,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCreatedRides,
              child: Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      );
    }

    if (_createdRides.isEmpty) {
      return Center(
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
              'No rides created yet',
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
                'Create your first ride to start carpooling',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.onSwitchToCreateRide != null) ...[
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: widget.onSwitchToCreateRide,
                icon: Icon(Icons.add),
                label: Text('Create Ride'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCreatedRides,
      color: Colors.orange,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _createdRides.length,
        itemBuilder: (context, index) {
          return CreatedRideItem(
            ride: _createdRides[index],
            onManageRequests: (ride) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RideRequestManagementPage(
                    rideId: ride['_id'],
                    rideDetails: ride,
                  ),
                ),
              ).then((_) {
                // Refresh rides when coming back from request management
                _loadCreatedRides();
              });
            },
            onRefresh: _loadCreatedRides,
          );
        },
      ),
    );
  }

  Widget _buildRequestedRidesTab() {
    if (_isLoadingRequested) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('Loading your requests...',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (_errorMessageRequested.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(_errorMessageRequested,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequestedRides,
              child: Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      );
    }

    if (_requestedRides.isEmpty) {
      return Center(
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
                style: TextStyle(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequestedRides,
      color: Colors.orange,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _requestedRides.length,
        itemBuilder: (context, index) {
          return RequestedRideItem(
            request: _requestedRides[index],
            onRefresh: _loadRequestedRides,
          );
        },
      ),
    );
  }
}

class CreatedRideItem extends StatelessWidget {
  final dynamic ride;
  final Function(dynamic) onManageRequests;
  final VoidCallback onRefresh;

  const CreatedRideItem({
    Key? key,
    required this.ride,
    required this.onManageRequests,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safe calculation of request statistics
    final List requests = ride['requests'] ?? [];
    final int pendingRequests = requests.where((req) {
      return req is Map<String, dynamic> && req['status'] == 'pending';
    }).length;
    final int approvedRequests = requests.where((req) {
      return req is Map<String, dynamic> && req['status'] == 'approved';
    }).length;
    final int totalRequests = requests.length;

    // Format date
    String formattedDate = '';
    if (ride['date'] != null) {
      try {
        final date = DateTime.parse(ride['date']);
        formattedDate = DateFormat('MMM dd, yyyy - HH:mm').format(date);
      } catch (e) {
        formattedDate = ride['date'].toString();
      }
    }

    // Calculate available seats
    final int capacity = ride['capacity'] ?? 0;
    final int availableSeats = capacity - approvedRequests;

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
            // Route header
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
                if (pendingRequests > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      '$pendingRequests NEW',
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 12),

            // Date and capacity info
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
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.green[600], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Capacity: $capacity | Available: $availableSeats',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (totalRequests > 0) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_outline,
                        color: Colors.blue[600], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Requests: $totalRequests total, $pendingRequests pending, $approvedRequests approved',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 12),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onManageRequests(ride),
                icon: Icon(Icons.settings),
                label: Text(
                  totalRequests > 0
                      ? 'Manage Requests ($totalRequests)'
                      : 'Manage Requests',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      pendingRequests > 0 ? Colors.red : Colors.orange,
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
      ),
    );
  }
}

class RequestedRideItem extends StatelessWidget {
  final dynamic request;
  final VoidCallback onRefresh;

  const RequestedRideItem({
    Key? key,
    required this.request,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ride = request['ride'];
    final status = request['status'] ?? 'pending';

    // Format date
    String formattedDate = '';
    if (ride != null && ride['date'] != null) {
      try {
        final date = DateTime.parse(ride['date']);
        formattedDate = DateFormat('MMM dd, yyyy - HH:mm').format(date);
      } catch (e) {
        formattedDate = ride['date'].toString();
      }
    }

    // Status styling - Fixed: Use MaterialColor instead of Color
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
            // Route and status header
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor[800]),
                      SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Date and host info
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
                        Icon(Icons.person, color: Colors.orange[600], size: 20),
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
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_money,
                        color: Colors.green[600], size: 16),
                    Text(
                      '₹${ride['price']}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
