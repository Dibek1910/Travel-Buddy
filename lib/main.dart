import 'package:flutter/material.dart';
import 'package:travel_buddy/Screens/home_screen.dart';
import 'package:travel_buddy/Screens/login_screen.dart';
import 'package:travel_buddy/Screens/signup_screen.dart';
import 'package:travel_buddy/Screens/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? authToken = prefs.getString('authToken');

  runApp(MyApp(authToken: authToken));
}

class MyApp extends StatelessWidget {
  final String? authToken;

  const MyApp({Key? key, this.authToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Buddy - Carpool App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home:
          authToken != null
              ? UserDashboard(authToken: authToken!)
              : HomeScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}
