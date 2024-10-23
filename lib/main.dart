// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gxljjvqualreuvptxeyw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4bGpqdnF1YWxyZXV2cHR4ZXl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg0MTIxMzksImV4cCI6MjA0Mzk4ODEzOX0.iYC63sP7r2G__stmOo_ejilE9vWWsjUDbUp8v4hgt58',
  );

  // Stripe.publishableKey = 'your_publishable_key_here';
  // await Stripe.instance.applySettings();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
