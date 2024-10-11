import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class AuthState {
  final UserModel? user;
  final bool isLoading;

  AuthState({this.user, this.isLoading = false});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabaseClient;

  AuthNotifier(this._supabaseClient) : super(AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
      await _fetchUser(session.user.id);
    } else {
      state = AuthState(isLoading: false);
    }
  }

  Future<void> _fetchUser(String userId) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      if (response != null) {
        state = AuthState(user: UserModel.fromJson(response), isLoading: false);
      } else {
        state = AuthState(isLoading: false);
      }
    } catch (e) {
      print('Error fetching user: $e');
      state = AuthState(isLoading: false);
    }
  }

  Future<void> signUp({required String email, required String password, required String name}) async {
  if (!kIsWeb) {
    throw Exception('Sign up is only available on web');
  }
  state = AuthState(isLoading: true);
  try {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},  // Include the name in the user metadata
    );
    
    // The trigger will automatically create the user record in public.users
    
    state = AuthState(isLoading: false);
  } catch (e) {
    state = AuthState(isLoading: false);
    rethrow;
  }
}

   Future<void> signIn({required String email, required String password}) async {
    state = AuthState(isLoading: true);
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _fetchUser(response.user!.id);
      
      // Check if the email is verified and update the user table if necessary
      if (response.user!.emailConfirmedAt != null && state.user != null && !state.user!.isVerified) {
        await _updateEmailVerificationStatus(response.user!.id);
      }
    } catch (e) {
      state = AuthState(isLoading: false);
      rethrow;
    }
  }

  Future<void> _updateEmailVerificationStatus(String userId) async {
    await _supabaseClient.from('users').update({'is_verified': true}).eq('id', userId);
    // Fetch the updated user data
    await _fetchUser(userId);
  }


  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
    state = AuthState(isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(supabaseClientProvider));
});