import 'dart:typed_data';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth_datasource.dart' as auth_ds;

class AuthRepositoryImpl implements AuthRepository {
  final auth_ds.AuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<User> login(String email, String password) async {
    return await datasource.login(email, password);
  }

  @override
  Future<User> register(String email, String password, String name) async {
    return await datasource.register(email, password, name);
  }

  @override
  Future<void> logout() {
    return datasource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await datasource.getCurrentUser();
  }

  @override
  Future<User> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
  }) async {
    return await datasource.updateProfile(
      userId: userId,
      name: name,
      phone: phone,
      address: address,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<String> uploadAvatar(String userId, Uint8List imageBytes, String fileName) async {
    return await datasource.uploadAvatar(userId, imageBytes, fileName);
  }
}
