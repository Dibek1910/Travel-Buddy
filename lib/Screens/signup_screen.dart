import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:travel_buddy/Screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _msg = 'Please fill in the following details';
  String _status = 'Register User';
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 24.0),
                ),
                const Text(
                  'Sign up to avail our car pooling services.',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
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
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        TextField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
                        ),
                        const SizedBox(height: 10.0),
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
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _handleSubmit(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[400],
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
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

  Future<void> _handleSubmit() async {
    setState(() {
      _status = 'Registering User...';
      _isLoading = true;
    });

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _status = 'Please fill all fields';
        _msg = 'All fields are required. Please fill them.';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://carpool-backend.devashish-roy.com/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "firstName": _firstNameController.text,
          "lastName": _lastNameController.text,
          "email": _emailController.text,
          "password": _passwordController.text
        }),
      );

      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final success = responseData['success'] as bool;
        final message = responseData['message'] as String;

        setState(() {
          _msg = message;
          _status = success ? 'Registered' : 'Registration Failed';
        });

        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      } else if (response.statusCode == 409) {
        setState(() {
          _msg = 'User already exists';
          _status = 'Registration Failed';
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        setState(() {
          _status = 'Registration Failed';
          _msg = 'Registration Failed';
        });
      }
    } catch (error) {
      setState(() {
        _msg = 'Registration Failed';
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
