import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:travel_buddy/utils/RideRequestManagementPage.dart';
import 'package:travel_buddy/utils/UpdateRideDetailsPage.dart';

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
  List<dynamic> _createdRides = [];
  bool _isLoadingCreated = true;
  String _errorMessageCreated = '';

  @override
  void initState() {
    super.initState();
    _loadCreatedRides();
  }

  @override
  void dispose() {
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

  void _updateRideData(String rideId, String requestId, String newStatus) {
    if (!mounted) return;

    try {
      setState(() {
        int rideIndex = -1;
        for (int i = 0; i < _createdRides.length; i++) {
          final ride = _createdRides[i];
          if (ride is Map<String, dynamic>) {
            final currentRideId = ride['_id']?.toString();
            if (currentRideId == rideId) {
              rideIndex = i;
              break;
            }
          }
        }

        if (rideIndex != -1) {
          final ride = _createdRides[rideIndex];
          if (ride is Map<String, dynamic>) {
            final requests = List.from(ride['requests'] ?? []);

            int requestIndex = -1;
            for (int i = 0; i < requests.length; i++) {
              final req = requests[i];
              if (req is Map<String, dynamic>) {
                final currentRequestId = req['_id']?.toString();
                if (currentRequestId == requestId) {
                  requestIndex = i;
                  break;
                }
              }
            }

            if (requestIndex != -1) {
              final updatedRequest = Map<String, dynamic>.from(
                requests[requestIndex],
              );
              updatedRequest['status'] = newStatus;
              requests[requestIndex] = updatedRequest;

              final updatedRide = Map<String, dynamic>.from(ride);
              updatedRide['requests'] = requests;
              _createdRides[rideIndex] = updatedRide;

              print(
                'DEBUG: Successfully updated ride data - RideID: $rideId, RequestID: $requestId, Status: $newStatus',
              );
            } else {
              print(
                'DEBUG: Warning - Could not find request to update with ID: $requestId',
              );
            }
          }
        } else {
          print(
            'DEBUG: Warning - Could not find ride to update with ID: $rideId',
          );
        }
      });
    } catch (error) {
      print('DEBUG: Error in _updateRideData: $error');
    }
  }

  Future<void> _cancelRide(String rideId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Ride'),
          content: Text(
            'Are you sure you want to cancel this ride? This action cannot be undone and all passengers will be notified.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Keep Ride'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Cancel Ride'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final result = await RideService.cancelRide(rideId);

        if (result['success']) {
          setState(() {
            _createdRides.removeWhere((ride) {
              if (ride is Map<String, dynamic>) {
                return ride['_id'] == rideId;
              }
              return false;
            });
          });

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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to cancel ride'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling ride: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadCreatedRides),
        ],
      ),
      body: _buildCreatedRidesContent(),
    );
  }

  Widget _buildCreatedRidesContent() {
    if (_isLoadingCreated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Loading your rides...',
              style: TextStyle(color: Colors.grey[600]),
            ),
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
              child: Text(
                _errorMessageCreated,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
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
                style: TextStyle(color: Colors.grey[500]),
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
            onManageRequests: (ride) async {
              if (ride is Map<String, dynamic>) {
                final rideId = ride['_id']?.toString();
                if (rideId != null) {
                  final rideDetails = await RideService.getRideById(rideId);

                  if (rideDetails['success']) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RideRequestManagementPage(
                              rideId: rideId,
                              rideDetails: rideDetails['rideDetails'],
                              onRequestStatusChanged: _updateRideData,
                            ),
                      ),
                    ).then((_) {
                      _loadCreatedRides();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load ride details'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid ride data'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            onEditRide: (ride) {
              if (ride is Map<String, dynamic>) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UpdateRideDetailsPage(
                          rideDetails: ride,
                          onRideUpdated: _loadCreatedRides,
                        ),
                  ),
                );
              }
            },
            onCancelRide: (ride) {
              if (ride is Map<String, dynamic>) {
                final rideId = ride['_id']?.toString();
                if (rideId != null) {
                  _cancelRide(rideId);
                }
              }
            },
            onRefresh: _loadCreatedRides,
          );
        },
      ),
    );
  }
}

class CreatedRideItem extends StatelessWidget {
  final dynamic ride;
  final Function(dynamic) onManageRequests;
  final Function(dynamic) onEditRide;
  final Function(dynamic) onCancelRide;
  final VoidCallback onRefresh;

  const CreatedRideItem({
    Key? key,
    required this.ride,
    required this.onManageRequests,
    required this.onEditRide,
    required this.onCancelRide,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ride is! Map<String, dynamic>) {
      return Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Invalid ride data', style: TextStyle(color: Colors.red)),
        ),
      );
    }

    final Map<String, dynamic> rideData = ride as Map<String, dynamic>;
    final List requests = rideData['requests'] ?? [];

    final int pendingRequests =
        requests.where((req) {
          return req is Map<String, dynamic> && req['status'] == 'pending';
        }).length;

    final int totalRequests = requests.length;

    String formattedDate = '';
    if (rideData['date'] != null) {
      try {
        final date = DateTime.parse(rideData['date']);
        formattedDate = DateFormat('MMM dd, yyyy - HH:mm').format(date);
      } catch (e) {
        formattedDate = rideData['date'].toString();
      }
    }

    final int capacity = rideData['capacity'] ?? 0;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${rideData['from'] ?? 'Unknown'} → ${rideData['to'] ?? 'Unknown'}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                        'Total Capacity: $capacity seats',
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
                    Icon(
                      Icons.people_outline,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Total Requests: $totalRequests${pendingRequests > 0 ? ' ($pendingRequests pending)' : ''}',
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

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onManageRequests(ride),
                    icon: Icon(Icons.settings, size: 18),
                    label: Text(
                      totalRequests > 0 ? 'Manage ($totalRequests)' : 'Manage',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          pendingRequests > 0 ? Colors.red : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onEditRide(ride),
                    icon: Icon(Icons.edit, size: 18),
                    label: Text('Edit', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onCancelRide(ride),
                    icon: Icon(Icons.cancel, size: 18),
                    label: Text('Cancel', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
