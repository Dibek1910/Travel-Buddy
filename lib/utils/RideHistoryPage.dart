import 'package:flutter/material.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:travel_buddy/utils/RideDetailsScreen.dart';

class RideHistoryPage extends StatefulWidget {
  final String authToken;

  const RideHistoryPage({Key? key, required this.authToken}) : super(key: key);

  @override
  _RideHistoryPageState createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _rideHistory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRideHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRideHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await RideService.getUserRideHistory();

      if (result['success']) {
        setState(() {
          _rideHistory = result['rides'];
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
        _errorMessage = 'Error fetching ride history: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'As Passenger'),
            Tab(text: 'As Host'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _rideHistory == null
                  ? Center(child: Text('No ride history found'))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRideList(_rideHistory!['asPassenger'] ?? []),
                        _buildRideList(_rideHistory!['asHost'] ?? []),
                      ],
                    ),
    );
  }

  Widget _buildRideList(List<dynamic> rides) {
    if (rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No ride history found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRideHistory,
      child: ListView.builder(
        itemCount: rides.length,
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final ride = rides[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                            '${ride['from']} → ${ride['to']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
                                  'Date: ${ride['date']}'),
                              SizedBox(height: 8),
                              _buildInfoRow(Icons.people,
                                  'Capacity: ${ride['capacity']}'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(Icons.attach_money,
                                  'Price: ${ride['price']}'),
                              SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.person,
                                'Host: ${ride['host']['firstName']} ${ride['host']['lastName']}',
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
          );
        },
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
