import 'package:flutter/material.dart';
import 'package:travel_buddy/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _message = 'Enter your email to receive an OTP';
  int _currentStep = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40.0),
              Icon(Icons.lock_reset, size: 80.0, color: Colors.orange),
              const SizedBox(height: 24.0),
              Text(
                'Reset Your Password',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Text(
                _message,
                style: TextStyle(
                  color:
                      _message.contains('error')
                          ? Colors.red
                          : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      if (_currentStep == 0) _buildEmailStep(),
                      if (_currentStep == 1) _buildOtpStep(),
                      if (_currentStep == 2) _buildPasswordStep(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email, color: Colors.orange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOtp,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child:
              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                    'Send OTP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter OTP',
            prefixIcon: Icon(Icons.security, color: Colors.orange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child:
              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'New Password',
            prefixIcon: Icon(Icons.lock, color: Colors.orange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: _isLoading ? null : _updatePassword,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child:
              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                    'Update Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
        ),
      ],
    );
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _message = 'Please enter your email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Sending OTP...';
    });

    try {
      final result = await AuthService.sendOtp(_emailController.text);

      setState(() {
        _isLoading = false;
        if (result['success']) {
          _currentStep = 1;
          _message = 'OTP sent to your email. Please check and enter it below.';
        } else {
          _message = result['message'];
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _message = 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _message = 'Please enter the OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Verifying OTP...';
    });

    try {
      final result = await AuthService.verifyOtp(
        _emailController.text,
        _otpController.text,
      );

      setState(() {
        _isLoading = false;
        if (result['success']) {
          _currentStep = 2;
          _message = 'OTP verified! Please enter your new password.';
        } else {
          _message = result['message'];
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _message = 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _updatePassword() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _message = 'Please enter a new password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Updating password...';
    });

    try {
      final result = await AuthService.updatePassword(
        _emailController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
        _message = result['message'];
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _message = 'An error occurred. Please try again.';
      });
    }
  }
}
