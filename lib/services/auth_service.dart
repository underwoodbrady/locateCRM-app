import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<User?> getCurrentUser() async {
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser != null) {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', supabaseUser.id)
          .single();
      if (response.isNotEmpty) {
        return User.fromJson(response);
      }
    }
    return null;
  }

  Future<User> signIn(String email, String password) async {
    final response = await _supabase.auth
        .signInWithPassword(email: email, password: password);
    if (response.user == null) {
      throw Exception('Login failed');
    }
    final userResponse = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    if (response.user != null) {
      return User.fromJson(userResponse);
    }
    throw Exception('User data not found');
  }

  Future<User> signUp(String email, String password, String name) async {
    final response = await _supabase.auth.signUp(
      email:email,
      password:password,
      data: {'name': name},
    );
    if (response.user == null) {
      throw Exception('Sign up failed');
    }

    // Create user record in the users table
    final userResponse = await _supabase.from('users').insert({
      'id': response.user!.id,
      'email': email,
      'name': name,
      'is_verified': false,
      'last_active': DateTime.now().toIso8601String(),
      'last_sync': DateTime.now().toIso8601String(),
    });

    if (response.user != null) {
      return User.fromJson(userResponse.data[0]);
    }
    throw Exception('Failed to create user record');
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
