// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      if (authToken == null) {
        throw Exception('Authentication token not found in shared preferences');
      }

      final response = await http.get(
        Uri.parse('https://carpool-backend.devashish-roy.com/api/user/profile'),
        headers: {
          'accept': 'application/json',
          'Authorization':
              'Bearer $authToken', // Include the auth token in the request headers
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          userProfile = responseData['userProfile'];
          isLoading = false;
        });
        print('User profile fetched successfully');
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if (mounted && kDebugMode) {
        print('Error fetching user profile: $e');
      }
      // Handle error here
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content:
              Text('Failed to fetch user profile. Please try again later.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userProfile != null
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16.0,
                    dataRowHeight: 60.0,
                    headingRowHeight: 80.0,
                    horizontalMargin: 16.0,
                    dividerThickness: 2.0, // Add divider thickness for borders
                    decoration: BoxDecoration(
                      // Add border decoration
                      border: Border.all(color: Colors.grey), // Border color
                      borderRadius:
                          BorderRadius.circular(10.0), // Border radius
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Field',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0, // Increase font size
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Value',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0, // Increase font size
                          ),
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text(
                          'Full Name',
                          style: TextStyle(fontSize: 14.0), // Adjust font size
                        )),
                        DataCell(Text(
                          '${userProfile!['firstName']} ${userProfile!['lastName']}',
                          style: TextStyle(fontSize: 14.0), // Adjust font size
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Email',
                          style: TextStyle(fontSize: 14.0), // Adjust font size
                        )),
                        DataCell(Text(
                          '${userProfile!['email']}',
                          style: TextStyle(fontSize: 14.0), // Adjust font size
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Average Rating',
                          style: TextStyle(fontSize: 14.0), // Adjust font size
                        )),
                        DataCell(Text(
                          '${userProfile!['ratingStats']['averageRating']}',
                          style: TextStyle(fontSize: 14.0), // Adjust font size
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Total Ratings',
                          style: TextStyle(fontSize: 14.0), // Adjust font size
                        )),
                        DataCell(Text(
                          '${userProfile!['ratingStats']['totalRatings']}',
                          style: TextStyle(fontSize: 14.0), // Adjust font size
                        )),
                      ]),
                    ],
                  ),
                )
              : Center(child: Text('Failed to load user profile')),
    );
  }
}
