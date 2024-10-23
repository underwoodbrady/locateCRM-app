import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:html' as html;

import '../providers/organization_provider.dart'; // Only for web platform

class ChoosePlanScreen extends ConsumerStatefulWidget {
  const ChoosePlanScreen({Key? key}) : super(key: key);

  @override
  _ChoosePlanScreenState createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends ConsumerState<ChoosePlanScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : () => _handlePaidSubscription('small'),
              child: const Text('Small Plan - 35/month'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _handlePaidSubscription('medium'),
              child: const Text('Medium Plan - 95/month'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : _handleFreeTrial,
              child: const Text('Start Free Trial'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePaidSubscription(String plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create pending organization
      final organizationId = await ref.read(organizationProvider.notifier)
          .createPendingOrganization();

      if (organizationId == null) {
        throw Exception('Failed to create organization');
      }

      // Create form and submit it
      final form = html.FormElement();
      form.method = 'POST';
      form.action = plan == 'small' 
          ? 'https://payments.locatecrm.app/create-checkout-session-1'
          : 'https://payments.locatecrm.app/create-checkout-session-2';

      // Add organization ID as hidden input
      final orgInput = html.InputElement()
        ..type = 'hidden'
        ..name = 'organizationId'
        ..value = organizationId;
      form.append(orgInput);

      // Add to document, submit, and remove
      html.document.body?.append(form);
      form.submit();
      form.remove();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleFreeTrial() async {
    // Implement free trial logic
  }
}