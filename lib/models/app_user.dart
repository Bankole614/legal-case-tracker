class AppUser {
  final String? id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppUser({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString(),
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => [firstName, lastName].where((n) => n != null && n.isNotEmpty).join(' ');
}