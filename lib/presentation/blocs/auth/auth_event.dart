import 'package:equatable/equatable.dart';
import 'dart:typed_data';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  RegisterEvent(this.email, this.password, this.name);

  @override
  List<Object?> get props => [email, password, name];
}

class LogoutEvent extends AuthEvent {}

class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? phone;
  final String? address;
  final String? avatarUrl;

  UpdateProfileEvent({
    this.name,
    this.phone,
    this.address,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, phone, address, avatarUrl];
}

class GetCurrentUserEvent extends AuthEvent {}

class UploadAvatarEvent extends AuthEvent {
  final Uint8List imageBytes;
  final String fileName;

  UploadAvatarEvent(this.imageBytes, this.fileName);

  @override
  List<Object?> get props => [imageBytes, fileName];
}
