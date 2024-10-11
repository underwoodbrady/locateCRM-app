// screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'verify_email.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: const Center(
          child: Text('Sign up is only available on web'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleSignup,
                    child: const Text('Sign Up'),
                  ),
          ],
        ),
      ),
    );
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).signUp(
              email: _emailController.text,
              password: _passwordController.text,
              name: _nameController.text,
            );
        // Only navigate to VerifyEmailScreen if sign up was successful
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const VerifyEmailScreen(),
          ),
        );
      } catch (e) {
        // Show error message if sign up failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}