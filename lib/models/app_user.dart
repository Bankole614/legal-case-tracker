class AppUser {
  final String id;
  final String? email;
  final String? name;
  AppUser({required this.id, this.email, this.name});
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(id: json['id']?.toString() ?? '', email: json['email'] as String?, name: json['name'] as String?);
  }
}
