import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_buddy/Screens/forgot_password_screen.dart';
import 'package:travel_buddy/Screens/user_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _msg = 'Please fill in your credentials';
  String _status = 'Sign in';
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign in to your account',
                  style: TextStyle(fontSize: 24.0),
                ),
                Text(
                  'User Login',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
                ),
                Text(_msg),
                const SizedBox(height: 20.0),
                Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.orange[400],
                              ),
                              child: const Text('Forgot password?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed:
                              _isLoading ? null : () => _handleSubmit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[400],
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text(_status),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    setState(() {
      _status = 'Signing in...';
      _isLoading = true;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _status = 'Please Enter Email and Password';
        _msg = 'Email or Password fields are empty. Please fill both of them.';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://carpool-backend.devashish-roy.com/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final success = responseData['success'] as bool;

        if (success) {
          final authToken = responseData['token'] as String;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', authToken);

          final String bearerToken = 'Bearer $authToken';
          await prefs.setString('authorization', bearerToken);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserDashboard(
                authToken: authToken,
              ),
            ),
          );

          setState(() {
            _msg = 'SUCCESSFUL SIGN IN!';
            _status = 'Signin successful';
          });
        } else {
          setState(() {
            _status = 'Please Try Again';
            _msg = 'INCORRECT CREDENTIALS';
          });
        }
      } else {
        setState(() {
          _status = 'Please Try Again';
          _msg = 'An error occurred. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        _status = 'Please Try Again';
        _msg = 'An error occurred. Please try again.';
      });
      if (kDebugMode) {
        print(error);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
