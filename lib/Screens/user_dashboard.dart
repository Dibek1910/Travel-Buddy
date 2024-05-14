import 'package:flutter/material.dart';
import 'package:travel_buddy/Screens/logout_dialog.dart';

import 'package:travel_buddy/UserDashboardScreens/create_ride_page.dart';

import 'package:travel_buddy/UserDashboardScreens/my_requests_page.dart';
import 'package:travel_buddy/UserDashboardScreens/my_rides_page.dart';
import 'package:travel_buddy/UserDashboardScreens/search_ride_page.dart';
import 'package:travel_buddy/utils/RideHistoryPage.dart';
import 'package:travel_buddy/utils/my_profile.dart';

class UserDashboard extends StatefulWidget {
  final String authToken;

  const UserDashboard({Key? key, required this.authToken}) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    MyRidesPage(
      authToken: '',
    ),
    CreateRidePage(
      authToken: '',
    ),
    SearchRidePage(
      authToken: '',
    ),
    MyRequestsPage(
      authToken: '',
      updateRideStatusCallback: (String) {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
      ),
      body: _widgetOptions
          .elementAt(_selectedIndex), // Replace this with your body content
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/muj.jpg'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('My Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfile(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Ride History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideHistoryPage(
                      authToken: '',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return LogoutDialog();
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car, color: Colors.orange),
            label: 'My Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, color: Colors.orange),
            label: 'Create Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.orange),
            label: 'Search Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote, color: Colors.orange),
            label: 'My Requests',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
