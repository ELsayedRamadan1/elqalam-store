import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../domain/entities/user.dart' as app_user;

class AuthDatasource {
  final SupabaseClient client;

  AuthDatasource(this.client);

  Future<app_user.User> login(String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw Exception('Login failed');
    final profile = await client.from('profiles').select().eq('id', user.id).single();
    return app_user.User.fromJson(profile);
  }

  Future<app_user.User> register(String email, String password, String name) async {
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password.trim(),
    );
    final user = response.user;
    if (user == null) throw Exception('Registration failed');
    // Insert profile
    await client.from('profiles').insert({
      'id': user.id,
      'email': email.trim(),
      'name': name.trim(),
    });
    return app_user.User(id: user.id, email: email, name: name);
  }

  Future<void> logout() async {
    await client.auth.signOut();
  }

  Future<app_user.User?> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final profile = await client.from('profiles').select().eq('id', user.id).single();
    return app_user.User.fromJson(profile);
  }
}
