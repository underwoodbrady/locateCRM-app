import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locatecrm_app/models/organization.dart';
import 'dart:html' as html;

import 'package:locatecrm_app/providers/organization_provider.dart';

class FinalizeOrganizationScreen extends ConsumerStatefulWidget {
  const FinalizeOrganizationScreen({Key? key}) : super(key: key);

  @override
  _FinalizeOrganizationScreenState createState() =>
      _FinalizeOrganizationScreenState();
}

class _FinalizeOrganizationScreenState
    extends ConsumerState<FinalizeOrganizationScreen> {
  int _currentStep = 1;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedIndustry;
  bool _isLoading = false;

  final List<String> _industries = [
    'Real Estate',
    'Insurance',
    'Home Services',
    'Solar',
    'Other Sales',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Organization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 3; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= _currentStep ? Colors.blue : Colors.grey[300],
                    ),
                    child: Center(
                      child: Text(
                        '$i',
                        style: TextStyle(
                          color: i <= _currentStep ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            // Content based on current step
            Expanded(
              child: _buildCurrentStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildOrganizationDetails();
      case 2:
        return _buildInviteMembers();
      case 3:
        return _buildFinalSteps();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOrganizationDetails() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Organization Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Company Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a company name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedIndustry,
            decoration: const InputDecoration(labelText: 'Company Industry'),
            items: _industries.map((String industry) {
              return DropdownMenuItem(
                value: industry,
                child: Text(industry),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select an industry';
              }
              return null;
            },
            onChanged: (String? newValue) {
              setState(() {
                _selectedIndustry = newValue;
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSaveOrganizationDetails,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Save Information'),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteMembers() {
    return ref.watch(organizationProvider).when(
      data: (organization) {
        final maxUsers = organization?.plan == 1 ? 5 : 20;
        final currentInvites = organization?.userInvites.length ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Invite Members',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              '${currentInvites + 1} / $maxUsers slots filled',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: currentInvites + 1 >= maxUsers || _isLoading
                  ? null
                  : _handleInviteMember,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Invite Member'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleContinueToFinal,
              child: const Text('Continue'),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildFinalSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Final Steps',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          },
          child: const Text('Go to Dashboard'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            html.window.open('https://play.google.com/store', '_blank');
          },
          child: const Text('Download App'),
        ),
      ],
    );
  }

  Future<void> _handleSaveOrganizationDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref.read(organizationProvider.notifier).updateOrganizationDetails(
              name: _nameController.text,
              businessType: _selectedIndustry!,
            );
        setState(() {
          _currentStep = 2;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleInviteMember() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref
            .read(organizationProvider.notifier)
            .inviteMember(_emailController.text);
        _emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation sent!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleContinueToFinal() {
    setState(() {
      _currentStep = 3;
    });
  }
}