import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyRequestsPage extends StatefulWidget {
  final String authToken;

  const MyRequestsPage({
    Key? key,
    required this.authToken,
    required Null Function(dynamic String) updateRideStatusCallback,
  }) : super(key: key);

  @override
  _MyRequestsPageState createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  List<dynamic> _requestedRides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRequests();
  }

  Future<void> _fetchUserRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse(
            'https://carpool-backend.devashish-roy.com/api/rides/user-requests'),
        headers: {
          'authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final success = responseData['success'] as bool;
        if (success) {
          final requests = responseData['requests'] as List<dynamic>;
          setState(() {
            _requestedRides = requests;
            _isLoading = false;
          });
        } else {
          print('Failed to fetch user requests: ${responseData['message']}');
        }
      } else {
        print(
            'Failed to fetch user requests. Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch user requests: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final uniqueRequestedRides = <String, dynamic>{};

    _requestedRides.forEach((request) {
      if (request != null &&
          request['ride'] != null &&
          request['ride']['date'] != null) {
        final rideDate = DateTime.parse(request['ride']['date']);
        if (rideDate.isAfter(currentDate) ||
            rideDate.isAtSameMomentAs(currentDate)) {
          final rideId = request['ride']['_id'];
          if (!uniqueRequestedRides.containsKey(rideId)) {
            uniqueRequestedRides[rideId] = request;
          }
        }
      }
    });

    final futureRequestedRides = uniqueRequestedRides.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Requests'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : futureRequestedRides.isNotEmpty
              ? ListView.builder(
                  itemCount: futureRequestedRides.length,
                  itemBuilder: (context, index) {
                    final request = futureRequestedRides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            'From: ${request['ride']['from']} - To: ${request['ride']['to']}',
                          ),
                          subtitle: Text('Date: ${request['ride']['date']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  _showCancelConfirmationDialog(
                                      context, request['ride']['_id']);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  _updateRideStatus(
                                      request['ride']['_id'], 'accepted');
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Accept',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  _updateRideStatus(
                                      request['ride']['_id'], 'rejected');
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Reject',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(child: Text('No future requests found')),
    );
  }

  Future<void> _showCancelConfirmationDialog(
      BuildContext context, String rideId) async {
    final bool? result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Ride'),
        content: Text('Are you sure you want to cancel this ride request?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(true); // Return true if the user confirms
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(false); // Return false if the user cancels
            },
            child: Text('No'),
          ),
        ],
      ),
    );

    if (result == true) {
      _cancelRequest(rideId);
    }
  }

  Future<void> _cancelRequest(String rideId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('https://carpool-backend.devashish-roy.com/api/rides/cancel'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requestId': rideId,
        }),
      );

      final responseData = jsonDecode(response.body);
      final success = responseData['success'] as bool;
      final message = responseData['message'] as String;

      if (response.statusCode == 200) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        throw Exception(
            'Failed to cancel request. Server error ${response.statusCode}: $message');
      }
    } catch (error) {
      print('Error cancelling request: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to cancel request. Please try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _updateRideStatus(String rideId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse(
            'https://carpool-backend.devashish-roy.com/api/rides/update-status'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requestId': rideId,
          'status': status,
        }),
      );

      final responseData = jsonDecode(response.body);
      final success = responseData['success'] as bool;
      final message = responseData['message'] as String;

      if (response.statusCode == 200) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ));
          // Refresh the list after updating status
          _fetchUserRequests();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        throw Exception(
            'Failed to update ride status. Server error ${response.statusCode}: $message');
      }
    } catch (error) {
      print('Error updating ride status: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update ride status. Please try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
