class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin', 'cashier'
  final String? profilePhotoUrl;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePhotoUrl,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'cashier',
      profilePhotoUrl: json['profile_photo_url'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'role': role, 'is_active': isActive};
  }
}
