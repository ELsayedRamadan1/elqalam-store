import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    this.avatarUrl,
  });

  // BlocBuilder يلاحظ أي تغيير في أي field
  @override
  List<Object?> get props => [id, email, name, phone, address, avatarUrl];
}
