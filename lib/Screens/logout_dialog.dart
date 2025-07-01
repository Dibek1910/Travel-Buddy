import 'package:flutter/material.dart';
import 'package:travel_buddy/services/auth_service.dart';
import 'package:travel_buddy/Screens/login_screen.dart';

class LogoutDialog extends StatefulWidget {
  @override
  _LogoutDialogState createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Logout'),
      content: _isLoggingOut
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            )
          : Text('Are you sure you want to logout?'),
      actions: _isLoggingOut
          ? []
          : [
              TextButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _performLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Logout'),
              ),
            ],
    );
  }

  Future<void> _performLogout(BuildContext dialogContext) async {
    if (!mounted) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Store the navigator reference before async operation
      final navigator = Navigator.of(dialogContext);

      // Perform logout
      await AuthService.logout();

      // Check if widget is still mounted before navigation
      if (mounted) {
        // Close the dialog first
        navigator.pop();

        // Navigate to login screen and clear all previous routes
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      // Handle logout error
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });

        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Alternative approach using a static method
class LogoutDialogHelper {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => LogoutDialog(),
    );
  }

  static Future<void> performLogout(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Logging out...'),
            ],
          ),
        ),
      );

      // Perform logout
      await AuthService.logout();

      // Navigate to login screen
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
