import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:travel_buddy/services/ride_service.dart';
import 'package:travel_buddy/services/interest_service.dart';
import 'package:travel_buddy/services/auth_service.dart';
import 'package:travel_buddy/utils/ride_details_screen.dart';
import 'package:travel_buddy/widgets/location_autocomplete_field.dart';

class SearchRidePage extends StatefulWidget {
  final String authToken;

  const SearchRidePage({super.key, required this.authToken});

  @override
  SearchRidePageState createState() => SearchRidePageState();
}

class SearchRidePageState extends State<SearchRidePage> {
  final logger = Logger();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _errorMessage = '';
  DateTime? _selectedDate;
  String? _currentUserId;
  bool _isSearchFormExpanded = true;

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
      logger.e('Error getting current user ID:', error: e);
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
      appBar: AppBar(
        title: Text('Search Rides'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchForm(),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchForm() {
    if (_hasSearched && !_isSearchFormExpanded) {
      return Container(
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 26),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_fromController.text} → ${_toController.text}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_dateController.text.isNotEmpty) ...[
                    SizedBox(height: 2),
                    Text(
                      _dateController.text,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _searchRides,
                  icon: Icon(Icons.refresh, color: Colors.orange, size: 20),
                  tooltip: 'Refresh search',
                  constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.all(4),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearchFormExpanded = true;
                    });
                  },
                  icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                  tooltip: 'Edit search',
                  constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.all(4),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 26),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasSearched) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearchFormExpanded = false;
                    });
                  },
                  icon: Icon(Icons.keyboard_arrow_up, color: Colors.grey),
                  tooltip: 'Minimize search form',
                  constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.all(4),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],

          Text(
            'From',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 6),
          LocationAutocompleteField(
            label: 'Pickup location',
            controller: _fromController,
            onLocationSelected: (location) {
              _fromController.text = location;
            },
          ),
          SizedBox(height: 12),

          Text(
            'To',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 6),
          LocationAutocompleteField(
            label: 'Destination',
            controller: _toController,
            onLocationSelected: (location) {
              _toController.text = location;
            },
          ),
          SizedBox(height: 12),

          Text(
            'Date (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 6),
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              leading: Icon(
                Icons.calendar_today,
                color: Colors.orange,
                size: 20,
              ),
              title: Text(
                _dateController.text.isEmpty
                    ? 'Select travel date'
                    : _dateController.text,
                style: TextStyle(
                  color:
                      _dateController.text.isEmpty
                          ? Colors.grey[600]
                          : Colors.black,
                  fontSize: 14,
                ),
              ),
              trailing:
                  _dateController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey, size: 18),
                        onPressed: () {
                          setState(() {
                            _dateController.clear();
                            _selectedDate = null;
                          });
                        },
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.all(4),
                      )
                      : Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
              onTap: _selectDate,
            ),
          ),
          SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _searchRides,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child:
                  _isLoading
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Searching...'),
                        ],
                      )
                      : Text(
                        'Search Rides',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Searching for rides...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchRides,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Try Again'),
            ),
          ],
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
            Icon(Icons.search, size: 80, color: Colors.grey[300]),
            SizedBox(height: 20),
            Text(
              'Enter your travel details above',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Find rides that match your route and schedule',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Icon(
              Icons.directions_car_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No rides found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria or get notified when rides become available',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addInterest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Get Notified When Available',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.list, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_searchResults.length} ride${_searchResults.length == 1 ? '' : 's'} found',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              if (_isSearchFormExpanded)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSearchFormExpanded = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: Text('Hide Search'),
                ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return _buildRideCard(_searchResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRideCard(dynamic ride) {
    final int capacity = ride['capacity'] ?? 0;
    final List requests = ride['requests'] ?? [];
    final int approvedRequests =
        requests.where((req) {
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
    final isCurrentUserHost =
        _currentUserId != null && hostId == _currentUserId;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideDetailsScreen(rideDetails: ride),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${ride['from']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${ride['to']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFull ? Colors.red[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isFull ? 'FULL' : '$availableSeats seats',
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

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Host: $hostName',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formattedDateTime,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (ride['price'] != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '₹${ride['price']}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isFull || isCurrentUserHost
                          ? null
                          : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        RideDetailsScreen(rideDetails: ride),
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCurrentUserHost
                            ? Colors.grey
                            : isFull
                            ? Colors.grey
                            : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isCurrentUserHost
                        ? 'Your Ride'
                        : isFull
                        ? 'Ride Full'
                        : 'View Details',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  Future<void> _searchRides() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasSearched = true;
      _isSearchFormExpanded = false;
    });

    try {
      final result = await RideService.searchRides(
        _fromController.text.isNotEmpty ? _fromController.text : null,
        _toController.text.isNotEmpty ? _toController.text : null,
        _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : null,
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
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please enter both pickup and destination locations',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final result = await InterestService.addInterest(
        _fromController.text,
        _toController.text,
      );
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Error adding interest: $error')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
