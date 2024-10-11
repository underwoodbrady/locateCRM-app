import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class OrganizationSetupScreen extends ConsumerStatefulWidget {
  const OrganizationSetupScreen({Key? key}) : super(key: key);

  @override
  _OrganizationSetupScreenState createState() => _OrganizationSetupScreenState();
}

class _OrganizationSetupScreenState extends ConsumerState<OrganizationSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _organizationNameController = TextEditingController();
  final _organizationIdController = TextEditingController();
  bool _isCreatingNewOrganization = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isCreatingNewOrganization ? 'Create a New Organization' : 'Join an Existing Organization',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              if (_isCreatingNewOrganization)
                TextFormField(
                  controller: _organizationNameController,
                  decoration: const InputDecoration(labelText: 'Organization Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an organization name';
                    }
                    return null;
                  },
                )
              else
                TextFormField(
                  controller: _organizationIdController,
                  decoration: const InputDecoration(labelText: 'Organization ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an organization ID';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleOrganizationSetup,
                child: Text(_isCreatingNewOrganization ? 'Create Organization' : 'Join Organization'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isCreatingNewOrganization = !_isCreatingNewOrganization;
                  });
                },
                child: Text(_isCreatingNewOrganization
                    ? 'Join an existing organization instead'
                    : 'Create a new organization instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOrganizationSetup() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement organization creation or joining logic
      if (_isCreatingNewOrganization) {
        // Create new organization
        print('Creating new organization: ${_organizationNameController.text}');
      } else {
        // Join existing organization
        print('Joining organization with ID: ${_organizationIdController.text}');
      }
    }
  }
}