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

    try {
      final tempUser = User.fromJson(userResponse);
      // Check if the email is verified and update the user table if necessary
      if (response.user!.emailConfirmedAt != null && !tempUser.isVerified) {
        await _updateEmailVerificationStatus(response.user!.id);
      }
      return tempUser;
    } catch (e) {
      throw Exception('User data not found');
    }
  }

  Future<void> _updateEmailVerificationStatus(String userId) async {
    await _supabase
        .from('users')
        .update({'is_verified': true}).eq('id', userId);
  }

  Future<void> signUp(String email, String password, String name) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    if (response.user == null) {
      throw Exception('Sign up failed');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
