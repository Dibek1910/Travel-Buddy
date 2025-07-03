import 'package:flutter/material.dart';
import 'package:travel_buddy/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String _message = '';
  String _userEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _otpFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length < 4) {
      return 'Please enter a valid OTP';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _getStepTitle(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStepDescription(),
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  _buildProgressIndicator(),
                  const SizedBox(height: 30),

                  if (_message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color:
                            _message.contains('success') ||
                                    _message.contains('sent')
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                        border: Border.all(
                          color:
                              _message.contains('success') ||
                                      _message.contains('sent')
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _message,
                        style: TextStyle(
                          color:
                              _message.contains('success') ||
                                      _message.contains('sent')
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildCurrentStepContent(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleNextStep,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Processing...'),
                                ],
                              )
                              : Text(
                                _getButtonText(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),

                  if (_currentStep == 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : _resendOtp,
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStepIndicator(0, 'Email'),
        Expanded(child: _buildProgressLine(0)),
        _buildStepIndicator(1, 'OTP'),
        Expanded(child: _buildProgressLine(1)),
        _buildStepIndicator(2, 'Password'),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step <= _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.orange : Colors.grey.shade300,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.orange : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step) {
    final isCompleted = step < _currentStep;
    return Container(
      height: 2,
      color: isCompleted ? Colors.orange : Colors.grey.shade300,
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildOtpStep();
      case 2:
        return _buildPasswordStep();
      default:
        return _buildEmailStep();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          validator: _validateEmail,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email, color: Colors.orange),
            hintText: 'Enter your registered email',
          ),
          onFieldSubmitted: (_) => _handleNextStep(),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        Text(
          'We sent a verification code to:',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          _userEmail,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _otpController,
          focusNode: _otpFocusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: _validateOtp,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: const InputDecoration(
            labelText: 'Enter OTP',
            prefixIcon: Icon(Icons.security, color: Colors.orange),
            hintText: '000000',
            counterText: '',
          ),
          onFieldSubmitted: (_) => _handleNextStep(),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        TextFormField(
          controller: _newPasswordController,
          focusNode: _newPasswordFocusNode,
          obscureText: _obscureNewPassword,
          textInputAction: TextInputAction.next,
          validator: _validateNewPassword,
          decoration: InputDecoration(
            labelText: 'New Password',
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.orange,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            hintText: 'Enter new password',
          ),
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          validator: _validateConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock, color: Colors.orange),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.orange,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            hintText: 'Confirm new password',
          ),
          onFieldSubmitted: (_) => _handleNextStep(),
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Enter Your Email';
      case 1:
        return 'Verify OTP';
      case 2:
        return 'Create New Password';
      default:
        return 'Reset Password';
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Enter your registered email address to receive a verification code';
      case 1:
        return 'Enter the 6-digit code sent to your email';
      case 2:
        return 'Create a strong new password for your account';
      default:
        return '';
    }
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Send OTP';
      case 1:
        return 'Verify OTP';
      case 2:
        return 'Update Password';
      default:
        return 'Next';
    }
  }

  Future<void> _handleNextStep() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      switch (_currentStep) {
        case 0:
          await _sendOtp();
          break;
        case 1:
          await _verifyOtp();
          break;
        case 2:
          await _updatePassword();
          break;
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _message = 'An unexpected error occurred. Please try again.';
        });
      }
    }
  }

  Future<void> _sendOtp() async {
    final result = await AuthService.sendOtp(_emailController.text.trim());

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _message = result['message'] ?? 'Unknown response';
    });

    if (result['success']) {
      setState(() {
        _userEmail = _emailController.text.trim();
        _currentStep = 1;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_otpFocusNode);
        }
      });
    }
  }

  Future<void> _verifyOtp() async {
    final result = await AuthService.verifyOtp(
      _userEmail,
      _otpController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _message = result['message'] ?? 'Unknown response';
    });

    if (result['success']) {
      setState(() {
        _currentStep = 2;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_newPasswordFocusNode);
        }
      });
    }
  }

  Future<void> _updatePassword() async {
    final result = await AuthService.updatePassword(
      _userEmail,
      _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _message = result['message'] ?? 'Unknown response';
    });

    if (result['success']) {
      _showSuccessDialog();
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final result = await AuthService.sendOtp(_userEmail);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _message = result['message'] ?? 'Unknown response';
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Success!'),
            ],
          ),
          content: const Text(
            'Your password has been updated successfully. You can now login with your new password.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Login Now'),
            ),
          ],
        );
      },
    );
  }
}
