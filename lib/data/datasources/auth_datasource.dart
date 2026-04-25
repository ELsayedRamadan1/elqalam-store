import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'dart:typed_data';

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
      debugPrint('Profile insert deferred: $e');
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

    final profile = await client.from('profiles').select().eq('id', userId).single();
    return UserModel.fromJson(profile);
  }

  Future<String> uploadAvatar(String userId, Uint8List imageBytes, String fileName) async {
    try {
      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
      final validExt = ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'].contains(ext) ? ext : 'jpg';
      final mimeType = (validExt == 'jpg' || validExt == 'jpeg') ? 'image/jpeg' : 'image/$validExt';

      // ── الخطوة 1: احذف كل الصور القديمة للمستخدم ──
      // نجيب قائمة كل الملفات في مجلد المستخدم
      try {
        final existingFiles = await client.storage.from('avatars').list(path: userId);
        if (existingFiles.isNotEmpty) {
          final pathsToDelete = existingFiles
              .map((f) => '$userId/${f.name}')
              .toList();
          await client.storage.from('avatars').remove(pathsToDelete);
          debugPrint('Deleted ${pathsToDelete.length} old avatar(s): $pathsToDelete');
        }
      } catch (e) {
        // مش مشكلة لو الحذف فشل — نكمل الرفع
        debugPrint('Could not delete old avatars (ok): $e');
      }

      // ── الخطوة 2: ارفع الصورة الجديدة باسم ثابت ──
      // timestamp في اسم الملف يضمن إن كل رفع = ملف جديد تماماً
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '$userId/avatar_$timestamp.$validExt';

      debugPrint('Uploading new avatar: avatars/$storagePath');

      await client.storage.from('avatars').uploadBinary(
        storagePath,
        imageBytes,
        fileOptions: FileOptions(
          contentType: mimeType,
          upsert: false, // false لأننا حذفنا القديمة وبنرفع بإسم جديد
        ),
      );

      // ── الخطوة 3: ارجع الـ URL مع cache buster ──
      final publicUrl = client.storage.from('avatars').getPublicUrl(storagePath);
      // الـ timestamp في الـ URL يجبر CachedNetworkImage يحمّل الصورة الجديدة
      final finalUrl = '$publicUrl?v=$timestamp';

      debugPrint('Avatar uploaded successfully: $finalUrl');
      return finalUrl;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      throw Exception('فشل في رفع الصورة: $e');
    }
  }
}
