import 'package:flutter/material.dart';
import 'package:travel_buddy/Screens/logout_dialog.dart';
import 'package:travel_buddy/UserDashboardScreens/create_ride_page.dart';
import 'package:travel_buddy/UserDashboardScreens/my_requests_page.dart';
import 'package:travel_buddy/UserDashboardScreens/my_rides_page.dart';
import 'package:travel_buddy/UserDashboardScreens/search_ride_page.dart';
import 'package:travel_buddy/utils/my_profile.dart';
import 'package:travel_buddy/services/auth_service.dart';

class UserDashboard extends StatefulWidget {
  final String authToken;

  const UserDashboard({Key? key, required this.authToken}) : super(key: key);

  @override
  UserDashboardState createState() => UserDashboardState();
}

class UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _initializeWidgets();
    _loadUserName();
  }

  void _initializeWidgets() {
    _widgetOptions = [
      MyRidesPage(
        authToken: widget.authToken,
        onSwitchToCreateRide: () => switchToTab(1),
      ),
      CreateRidePage(authToken: widget.authToken),
      SearchRidePage(authToken: widget.authToken),
      MyRequestsPage(
        authToken: widget.authToken,
        updateRideStatusCallback: (String status) {
          setState(() {});
        },
        onSwitchToSearchRide: () => switchToTab(2),
      ),
    ];
  }

  Future<void> _loadUserName() async {
    final userName = await AuthService.getUserName();
    setState(() {
      _userName = userName;
    });
  }

  void switchToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Travel Buddy'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome, ${_userName ?? 'User'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your Carpooling Companion',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.orange),
              title: Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfile(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.grey),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
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
        onTap: switchToTab,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About Travel Buddy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Travel Buddy - Your Carpooling Companion'),
              SizedBox(height: 10),
              Text('Version: 1.0.0'),
              SizedBox(height: 10),
              Text(
                  'A platform to share rides, reduce costs, and make travel more sustainable.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
