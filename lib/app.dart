import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locatecrm_app/screens/auth/unknown_route_screen.dart';
import 'screens/auth/finalize_organization_screen.dart';
import 'screens/auth/payment_success_screen.dart';
import 'screens/auth/setup_organization_screen.dart';
import 'screens/auth/choose_plan_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/get_free_trial_screen.dart';
import 'screens/main_app_dashboard.dart';
import 'providers/auth_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var user = ref.watch(authProvider);

    return MaterialApp(
      title: 'Locate CRM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: user != null
          ? (user.isVerified == true
              ? (user.organizationId != null
                  ? const MainAppDashboard()
                  : const OrganizationSetupScreen())
              : const VerifyEmailScreen())
          : const LoginScreen(),
      //Public routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/freetrial': (context) => const GetFreeTrialScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/payment_success': (context) => const PaymentSuccessScreen(),
      },
      //Protected routes
      onGenerateRoute:(settings){
        user = ref.watch(authProvider);
        if (user == null) {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        }

        switch (settings.name) {
          case '/dashboard':
            return MaterialPageRoute(
              builder: (context) => const MainAppDashboard(),
            );
          case '/setup_organization':
            return MaterialPageRoute(
              builder: (context) => const OrganizationSetupScreen(),
            );
          case '/choose_plan':
            return MaterialPageRoute(
              builder: (context) => const ChoosePlanScreen(),
            );
          case '/finalize_organization':
            return MaterialPageRoute(
              builder: (context) => const FinalizeOrganizationScreen(),
            );
          default:
            // Handle unknown routes
            return MaterialPageRoute(
              builder: (context) => const UnknownRouteScreen(),
            );
        }
      }
    );
  }
}
