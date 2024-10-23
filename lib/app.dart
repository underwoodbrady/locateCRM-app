import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/finalize_organization_screen.dart';
import 'screens/payment_success_screen.dart';
import 'screens/setup_organization_screen.dart';
import 'screens/choose_plan_screen.dart';
import 'screens/verify_email_screen.dart';
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
      home: user != null
          ? (user.isVerified == true
              ? (user.organizationId != null
                  ? const MainAppDashboard()
                  : const OrganizationSetupScreen())
              : const VerifyEmailScreen())
          : const SignUpScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/freetrial': (context) => const GetFreeTrialScreen(),
        '/dashboard': (context) => const MainAppDashboard(),
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/setup_organization': (context) => const OrganizationSetupScreen(),
        '/choose_plan': (context) => const ChoosePlanScreen(),
        '/payment_success': (context) => PaymentSuccessScreen(),
          '/finalize_organization': (context) => const FinalizeOrganizationScreen(),
      },
    );
  }
}
