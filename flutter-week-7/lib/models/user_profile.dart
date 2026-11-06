class UserProfile {
  final String name;
  final String email;
  final String phone;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory UserProfile.fromMap(Map map) => UserProfile(
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
      );

  Map<String, Object> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
      };
}
