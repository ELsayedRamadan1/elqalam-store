/// Pure domain entity.
class User {
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
}
