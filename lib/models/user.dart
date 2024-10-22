import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String? organizationId;
  final String email;
  final String name;
  final bool isVerified;
  final DateTime lastActive;
  final DateTime lastSync;

  User({
    required this.id,
    this.organizationId,
    required this.email,
    required this.name,
    required this.isVerified,
    required this.lastActive,
    required this.lastSync,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      organizationId: json['organization_id'],
      email: json['email'],
      name: json['name'],
      isVerified: json['is_verified'],
      lastActive: DateTime.parse(json['last_active']),
      lastSync: DateTime.parse(json['last_sync']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'email': email,
      'name': name,
      'is_verified': isVerified,
      'last_active': lastActive.toIso8601String(),
      'last_sync': lastSync.toIso8601String(),
    };
  }
}