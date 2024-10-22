import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: const Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Please verify your email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'We\'ve sent you a verification email. Please check your inbox and click the verification link.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Once you\'ve verified your email, you can close this tab and log in to your account.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}