import 'package:flutter/material.dart';
import 'package:travel_buddy/services/auth_service.dart';
import 'package:travel_buddy/Screens/home_screen.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  LogoutDialogState createState() => LogoutDialogState();
}

class LogoutDialogState extends State<LogoutDialog> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout'),
      content:
          _isLoggingOut
              ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Logging out...'),
                ],
              )
              : const Text('Are you sure you want to logout?'),
      actions:
          _isLoggingOut
              ? []
              : [
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _performLogout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
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
      await AuthService.logout();

      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();

        Navigator.of(dialogContext).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      if (dialogContext.mounted) {
        setState(() {
          _isLoggingOut = false;
        });

        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class LogoutDialogHelper {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const LogoutDialog(),
    );
  }

  static Future<void> performLogout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (BuildContext dialogContext) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Logging out...'),
                ],
              ),
            ),
      );

      await AuthService.logout();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
