import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locatecrm_app/screens/verify_email_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/get_free_trial_screen.dart';
import 'screens/main_app_dashboard.dart';
import 'providers/auth_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return MaterialApp(
      title: 'Sales Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: user != null ? (user.isVerified == false ? MainAppDashboard() : VerifyEmailScreen()): SignUpScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/freetrial': (context) => const GetFreeTrialScreen(),
        '/dashboard': (context) => const MainAppDashboard(),
        '/verify_email': (context) => const VerifyEmailScreen(),
      },
    );
  }
}