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
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      MyRidesPage(authToken: widget.authToken),
      CreateRidePage(authToken: widget.authToken),
      SearchRidePage(authToken: widget.authToken),
      MyRequestsPage(
        authToken: widget.authToken,
        updateRideStatusCallback: (String status) {
          // Refresh the page when a ride status is updated
          setState(() {});
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carpool Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Refresh the current page
              setState(() {
                _widgetOptions = [
                  MyRidesPage(authToken: widget.authToken),
                  CreateRidePage(authToken: widget.authToken),
                  SearchRidePage(authToken: widget.authToken),
                  MyRequestsPage(
                    authToken: widget.authToken,
                    updateRideStatusCallback: (String status) {
                      setState(() {});
                    },
                  ),
                ];
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Carpool App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.orange),
              title: Text('My Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfile(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.orange),
              title: Text('Ride History'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideHistoryPage(
                      authToken: widget.authToken,
                    ),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
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
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'My Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Create Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
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
