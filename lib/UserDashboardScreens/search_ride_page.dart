import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:travel_buddy/services/interest_service.dart';
import 'package:travel_buddy/services/auth_service.dart';
import 'package:travel_buddy/utils/RideDetailsScreen.dart';
import 'package:travel_buddy/widgets/location_autocomplete_field.dart';

class SearchRidePage extends StatefulWidget {
  final String authToken;

  const SearchRidePage({Key? key, required this.authToken}) : super(key: key);

  @override
  _SearchRidePageState createState() => _SearchRidePageState();
}

class _SearchRidePageState extends State<SearchRidePage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _errorMessage = '';
  DateTime? _selectedDate;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    try {
      final userId = await AuthService.getCurrentUserId();
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print('Error getting current user ID: $e');
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Search Form - Fixed at top
                Container(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.6, // Max 60% of screen
                  ),
                  child: SingleChildScrollView(
                    child: Card(
                      margin: EdgeInsets.all(16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Row(
                              children: [
                                Icon(Icons.search,
                                    color: Colors.orange, size: 28),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Find Your Ride',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Search for available rides',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 20),

                            // From Field
                            LocationAutocompleteField(
                              label: 'From',
                              controller: _fromController,
                              onLocationSelected: (location) {
                                _fromController.text = location;
                              },
                            ),
                            SizedBox(height: 16),

                            // To Field
                            LocationAutocompleteField(
                              label: 'To',
                              controller: _toController,
                              onLocationSelected: (location) {
                                _toController.text = location;
                              },
                            ),
                            SizedBox(height: 16),

                            // Date Field
                            TextField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                labelText: 'Date (Optional)',
                                prefixIcon: Icon(Icons.calendar_today,
                                    color: Colors.orange),
                                suffixIcon: _dateController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _dateController.clear();
                                            _selectedDate = null;
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                      color: Colors.orange, width: 2),
                                ),
                              ),
                              readOnly: true,
                              onTap: _selectDate,
                            ),
                            SizedBox(height: 20),

                            // Action Buttons
                            LayoutBuilder(
                              builder: (context, buttonConstraints) {
                                // Use column layout for smaller screens
                                if (buttonConstraints.maxWidth < 400) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed:
                                              _isLoading ? null : _searchRides,
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text('Searching...'),
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.search),
                                                    SizedBox(width: 8),
                                                    Text('Search Rides'),
                                                  ],
                                                ),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed:
                                              _isLoading ? null : _addInterest,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.notifications_active,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text('Notify Me'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // Use row layout for larger screens
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed:
                                              _isLoading ? null : _searchRides,
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Flexible(
                                                        child: Text(
                                                            'Searching...')),
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.search),
                                                    SizedBox(width: 8),
                                                    Flexible(
                                                        child: Text(
                                                            'Search Rides')),
                                                  ],
                                                ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : _addInterest,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.notifications_active,
                                                size: 20),
                                            SizedBox(width: 4),
                                            Text('Notify Me'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Results Section - Flexible to fill remaining space
                Expanded(
                  child: _buildSearchResults(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('Searching for rides...',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _searchRides,
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Icon(
              Icons.search,
              size: 60,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              'Search for rides',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Enter your pickup and destination to find available rides',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
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
                'No rides found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search criteria or check back later',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addInterest,
                icon: Icon(Icons.notifications_active),
                label: Text('Get Notified'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return RideSearchItem(
          ride: _searchResults[index],
          currentUserId: _currentUserId,
          onRideSelected: (ride) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RideDetailsScreen(
                  rideDetails: ride,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _searchRides() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasSearched = true;
    });

    try {
      final result = await RideService.searchRides(
        _fromController.text.isNotEmpty ? _fromController.text : null,
        _toController.text.isNotEmpty ? _toController.text : null,
        _dateController.text.isNotEmpty ? _dateController.text : null,
      );

      if (result['success']) {
        setState(() {
          _searchResults = result['rides'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to search rides';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error searching rides: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _addInterest() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both pickup and destination locations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = await InterestService.addInterest(
        _fromController.text,
        _toController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result['success'] ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(child: Text(result['message'])),
            ],
          ),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding interest: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class RideSearchItem extends StatelessWidget {
  final dynamic ride;
  final String? currentUserId;
  final Function(dynamic) onRideSelected;

  const RideSearchItem({
    Key? key,
    required this.ride,
    required this.currentUserId,
    required this.onRideSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int capacity = ride['capacity'] ?? 0;
    final List requests = ride['requests'] ?? [];
    final int approvedRequests = requests.where((req) {
      if (req is Map<String, dynamic> && req['status'] is String) {
        return req['status'] == 'approved';
      }
      return false;
    }).length;

    final int availableSeats = capacity - approvedRequests;
    final bool isFull = availableSeats <= 0;

    String formattedDateTime = '';
    if (ride['date'] != null) {
      try {
        final date = DateTime.parse(ride['date']);
        formattedDateTime = DateFormat('MMM dd, yyyy - HH:mm').format(date);
      } catch (e) {
        formattedDateTime = ride['date'];
      }
    }

    final host = ride['host'];
    final hostName = host != null ? host['firstName'] ?? 'Unknown' : 'Unknown';
    final hostId = host != null ? host['_id'] : null;

    final isCurrentUserHost = currentUserId != null && hostId == currentUserId;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => onRideSelected(ride),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route and Status Row
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
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFull ? Colors.red[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFull ? Colors.red : Colors.green,
                      ),
                    ),
                    child: Text(
                      isFull ? 'FULL' : '$availableSeats SEATS',
                      style: TextStyle(
                        color: isFull ? Colors.red[800] : Colors.green[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Host and Date Info
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
                        CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          radius: 20,
                          child: Text(
                            hostName[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Host: $hostName',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Date: $formattedDateTime',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (ride['price'] != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Text(
                              '₹${ride['price']}',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Description (if available)
              if (ride['description'] != null &&
                  ride['description'].isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ride['description'],
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              SizedBox(height: 12),

              // Action Button
              if (isCurrentUserHost) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.orange[600]),
                      SizedBox(width: 8),
                      Text(
                        'Your Ride',
                        style: TextStyle(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isFull ? null : () => onRideSelected(ride),
                    icon: Icon(isFull ? Icons.block : Icons.info_outline),
                    label: Text(
                      isFull ? 'Ride Full' : 'View Details & Request',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFull ? Colors.grey : Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
