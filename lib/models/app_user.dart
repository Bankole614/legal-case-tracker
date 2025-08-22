// lib/models/app_user.dart
import 'package:flutter/foundation.dart';

class AppUser {
  final String? id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool emailVerified;
  final bool phoneVerified;

  const AppUser({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.emailVerified = false,
    this.phoneVerified = false,
  });

  /// Factory that accepts various envelope shapes and key names.
  factory AppUser.fromJson(Map<String, dynamic> rawJson) {
    // Normalize possible envelope: { data: { ... } } or direct object
    final Map<String, dynamic> json;
    if (rawJson['data'] is Map<String, dynamic>) {
      json = Map<String, dynamic>.from(rawJson['data'] as Map);
    } else {
      json = Map<String, dynamic>.from(rawJson);
    }

    // Attempt to get name variants
    String? first;
    String? last;
    String? name = _nullIfEmpty(json['name'] ?? json['full_name'] ?? json['fullname']);

    if (json.containsKey('first_name') || json.containsKey('last_name')) {
      first = (json['first_name'] ?? json['firstname'])?.toString();
      last = (json['last_name'] ?? json['lastname'])?.toString();
    } else if (name != null) {
      // try to split a single name into first/last
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        first = parts.first;
        if (parts.length > 1) {
          last = parts.sublist(1).join(' ');
        }
      }
    }

    // Parse created/updated dates tolerantly (ISO string or epoch int (s or ms) )
    DateTime? parsedCreated = _parseDate(json['created_at'] ?? json['createdAt'] ?? json['created']);
    DateTime? parsedUpdated = _parseDate(json['updated_at'] ?? json['updatedAt'] ?? json['updated']);

    // Parse boolean verification flags from various possible keys
    bool emailVerified = _parseBool(json['is_email_verified'] ?? json['email_verified'] ?? json['verified'] ?? json['is_verified']);
    bool phoneVerified = _parseBool(json['is_phone_verified'] ?? json['phone_verified']);

    return AppUser(
      id: json['id']?.toString(),
      email: _nullIfEmpty(json['email']?.toString()),
      firstName: _nullIfEmpty(first),
      lastName: _nullIfEmpty(last),
      phone: _nullIfEmpty(json['phone']?.toString() ?? json['telephone']?.toString()),
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
      emailVerified: emailVerified,
      phoneVerified: phoneVerified,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
    bool? phoneVerified,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
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
      'is_email_verified': emailVerified,
      'is_phone_verified': phoneVerified,
    };
  }

  /// Single convenient display name (backwards-compatible with code expecting `user.name`)
  String get name {
    final f = fullName;
    if (f.isNotEmpty) return f;
    if (email != null && email!.isNotEmpty) {
      final local = email!.split('@').first;
      return local;
    }
    return 'User';
  }

  /// Returns "First Last" if any part exists
  String get fullName {
    final parts = <String>[];
    if (firstName != null && firstName!.trim().isNotEmpty) parts.add(firstName!.trim());
    if (lastName != null && lastName!.trim().isNotEmpty) parts.add(lastName!.trim());
    return parts.join(' ');
  }

  /// Initials for avatar
  String get initials {
    if (fullName.isNotEmpty) {
      final parts = fullName.split(RegExp(r'\s+'));
      final chars = parts.take(2).map((p) => p.trim().isNotEmpty ? p[0].toUpperCase() : '').join();
      return chars.isNotEmpty ? chars : 'U';
    }
    if (email != null && email!.isNotEmpty) return email![0].toUpperCase();
    return 'U';
  }

  /// true if either email or phone is verified (or require both? adapt to your logic)
  bool get isVerified => emailVerified || phoneVerified;

  @override
  String toString() {
    return 'AppUser(id: $id, name: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppUser &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              email == other.email &&
              firstName == other.firstName &&
              lastName == other.lastName;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ (firstName ?? '').hashCode ^ (lastName ?? '').hashCode;
}

/// Helpers

String? _nullIfEmpty(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  try {
    if (v is DateTime) return v;
    if (v is int) {
      // Could be seconds or milliseconds: detect by magnitude
      if (v > 9999999999) {
        return DateTime.fromMillisecondsSinceEpoch(v);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(v * 1000);
      }
    }
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      // try ISO parse first
      return DateTime.parse(s);
    }
  } catch (_) {
    // ignore parse error
  }
  return null;
}

bool _parseBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) {
    final s = v.toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }
  return false;
}
