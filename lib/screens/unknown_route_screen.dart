import 'package:flutter/material.dart';

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('This Route Was Not Found'),
      ),
      body: const Center(
        child: Text("Sorry! We couldn't find this route."),
      ),
    );
  }
}