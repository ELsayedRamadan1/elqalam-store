import 'dart:typed_data';

import '../../domain/repositories/auth_repository.dart';

class UploadAvatarUseCase {
  final AuthRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<String> call({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) {
    return repository.uploadAvatar(userId, imageBytes, fileName);
  }
}
