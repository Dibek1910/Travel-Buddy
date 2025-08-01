import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Terms and Conditions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Travel Buddy - Disclaimer\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: 'Regarding the Use of Travel Buddy\n',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24, thickness: 1),
                  Text(
                    'The Travel Buddy application has been developed solely as part of the teaching and learning process at Manipal University Jaipur (MUJ). It is a non-commercial, internal-use platform created to facilitate shared travel coordination among members of the MUJ community, including students, faculty, and staff.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please note the following important points:',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Divider(height: 24, thickness: 1),
                  const SizedBox(height: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bulletText(
                        'Travel Buddy is not a commercial ride-sharing or transportation service. It merely connects individuals who are independently planning to travel the same route, allowing them to voluntarily coordinate their journeys.',
                        index: 1,
                      ),
                      _bulletText(
                        'Users are solely responsible for their travel decisions. All communications, meeting arrangements, and shared rides facilitated through the platform are entirely at the users own discretion and risk.',
                        index: 2,
                      ),
                      _bulletText(
                        'No background checks or verification of users are performed by the university or the developers. Users are advised to exercise personal judgment and caution when connecting with others through the platform.',
                        index: 3,
                      ),
                      _bulletText(
                        'Manipal University Jaipur and the developers of this application bear no responsibility or liability for any personal, legal, or financial consequences arising out of the use of this app or any travel arrangements made via it.',
                        index: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'By using this application, you acknowledge and accept that:',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Divider(height: 24, thickness: 1),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dotText(
                        'The platform is experimental and educational in nature.',
                      ),
                      _dotText(
                        'You are responsible for your own safety, decisions, and interactions.',
                      ),
                      _dotText(
                        'You release MUJ and the development team from any liability arising from the use of this service.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'If you do not agree with these terms, please do not use the Travel Buddy platform.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _bulletText(String text, {required int index}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$index. ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.orange,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _dotText(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.orange,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}
