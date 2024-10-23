import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/organization_provider.dart';

class OrganizationSetupScreen extends ConsumerStatefulWidget {
  const OrganizationSetupScreen({Key? key}) : super(key: key);

  @override
  _OrganizationSetupScreenState createState() => _OrganizationSetupScreenState();
}

class _OrganizationSetupScreenState extends ConsumerState<OrganizationSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _organizationIdController = TextEditingController();
  bool _isLoading = false;
  bool _showJoinForm = false;

  @override
  void dispose() {
    _organizationIdController.dispose();
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_showJoinForm) ...[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showJoinForm = true;
                  });
                },
                child: const Text('Join an Organization'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/choose_plan');
                },
                child: const Text('Create an Organization'),
              ),
            ],
            if (_showJoinForm) ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
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
                      onPressed: _isLoading ? null : _handleJoinOrganization,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Join Organization'),
                    ),
                   TextButton(
                onPressed: () {
 setState(() {
                    _showJoinForm = false;
                  });                },
                child: const Text('Go Back'),
              ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleJoinOrganization() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });
    try {
      await ref.read(organizationProvider.notifier).joinOrganization(
            _organizationIdController.text,
          );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined organization'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to dashboard
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
}