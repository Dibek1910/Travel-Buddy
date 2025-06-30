import 'package:flutter/material.dart';
import 'package:travel_buddy/services/auth_service.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.logout, color: Colors.red),
          SizedBox(width: 10),
          Text('Logout'),
        ],
      ),
      content: Text('Are you sure you want to logout?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => _logout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text('Logout'),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final result = await AuthService.logout();

      if (result['success']) {
        // Navigate to login screen and clear navigation stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop(); // Close the dialog
      }
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: $error'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop(); // Close the dialog
    }
  }
}
