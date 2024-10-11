import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/organization_setup_screen.dart';
import 'providers/auth_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Sales Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: authState.user == null
              ? const LoginScreen()
              : authState.user!.isVerified
                  ? (authState.user!.organizationId == null
                      ? const OrganizationSetupScreen()
                      : const HomeScreen())
                  : const LoginScreen(),
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, _) {
            final error = ref.watch(authProvider.select((state) => state.error));
            if (error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
                ref.read(authProvider.notifier).state = ref.read(authProvider.notifier).state.copyWith(error: null);
              });
            }
            return child!;
          },
        );
      },
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}