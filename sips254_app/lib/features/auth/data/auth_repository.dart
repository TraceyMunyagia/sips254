import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient _client = SupabaseService.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> createProfile({required String userId, required String username}) async {
    await _client.from('profiles').insert({
      'id': userId,
      'username': username,
    });
  }
}