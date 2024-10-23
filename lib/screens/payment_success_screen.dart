import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locatecrm_app/providers/auth_provider.dart';
import 'dart:async';

import 'package:locatecrm_app/providers/organization_provider.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({
    Key? key,
  }) : super(key: key);

  @override
  _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  Timer? _pollingTimer;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Check immediately
    _checkStatus();

    // Then check every 2 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    try {
      final user = ref.watch(authProvider);
      final isReady = await ref
          .read(organizationProvider.notifier)
          .checkOrganizationStatus(user?.organizationId);

      if (isReady) {
        _pollingTimer?.cancel();
        setState(() {
          _isChecking = false;
        });
        // Navigate to dashboard after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pushReplacementNamed('/finalize_organization');
        });
      }
    } catch (e) {
      // Handle error
      print('Error checking status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_isChecking) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Setting up your organization...',
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const Text(
                  'Your organization is ready!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Redirecting to final setup...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
