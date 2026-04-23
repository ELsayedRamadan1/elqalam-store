import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class AuthDatasource {
  final SupabaseClient client;

  AuthDatasource(this.client);

  Future<User> login(String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = response.user;
    if (user == null) throw Exception('Login failed');
    final profile = await client.from('profiles').select().eq('id', user.id).single();
    return UserModel.fromJson(profile);
  }

  Future<User> register(String email, String password, String name) async {
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password.trim(),
    );
    final user = response.user;
    if (user == null) throw Exception('Registration failed');

    try {
      await client.from('profiles').insert({
        'id': user.id,
        'email': email.trim(),
        'name': name.trim(),
      });
    } catch (e) {
      // Profile insert may fail if email confirmation is required.
      debugPrint('Profile insert deferred (email confirmation pending): $e');
    }

    return UserModel(id: user.id, email: email.trim(), name: name.trim());
  }

  Future<void> logout() async {
    await client.auth.signOut();
  }

  Future<User?> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final profile = await client.from('profiles').select().eq('id', user.id).single();
    return UserModel.fromJson(profile);
  }

  Future<User> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isNotEmpty) {
      updates['updated_at'] = DateTime.now().toIso8601String();
      await client.from('profiles').update(updates).eq('id', userId);
    }

    // Return updated user
    final profile = await client.from('profiles').select().eq('id', userId).single();
    return UserModel.fromJson(profile);
  }
}
