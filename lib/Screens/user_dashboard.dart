import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class UserDashboardState extends State<UserDashboard>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWidgets();
    _loadUserName();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _validateSession();
    }
  }

  Future<void> _validateSession() async {
    final isValid = await AuthService.validateToken();
    if (!isValid && mounted) {
      _handleSessionExpired();
    }
  }

  void _handleSessionExpired() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Expired'),
          content: const Text('Your session has expired. Please login again.'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await AuthService.logout();
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _initializeWidgets() {
    _widgetOptions = [
      SearchRidePage(authToken: widget.authToken),
      CreateRidePage(authToken: widget.authToken),
      MyRidesPage(
        authToken: widget.authToken,
        onSwitchToCreateRide: () => switchToTab(1),
      ),
      MyRequestsPage(
        authToken: widget.authToken,
        updateRideStatusCallback: (String status) {
          if (mounted) setState(() {});
        },
        onSwitchToSearchRide: () => switchToTab(0),
      ),
    ];
  }

  Future<void> _loadUserName() async {
    try {
      final userName = await AuthService.getUserName();
      if (mounted) {
        setState(() {
          _userName = userName;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void switchToTab(int index) {
    if (mounted && index >= 0 && index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      switchToTab(0);
      return false;
    } else {
      return await _showExitConfirmation();
    }
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Exit'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Travel Buddy'),
          centerTitle: true,
          elevation: 2,
        ),
        drawer: _buildDrawer(),
        body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,

          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search Ride',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Create Ride',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'My Rides',
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
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
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
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.orange),
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome, ${_userName ?? 'User'}',
                  style: const TextStyle(
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
            leading: const Icon(Icons.account_circle, color: Colors.orange),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyProfile()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              LogoutDialogHelper.show(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Travel Buddy'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Travel Buddy - Your Carpooling Companion'),
              SizedBox(height: 10),
              Text('Version: 1.0.0'),
              SizedBox(height: 10),
              Text(
                'A platform to share rides, reduce costs, and make travel more sustainable.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
