import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String? organizationId;
  final String email;
  final String name;
  final bool isVerified;
  final DateTime? lastActive;
  final DateTime? lastSync;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    this.organizationId,
    required this.email,
    required this.name,
    required this.isVerified,
    this.lastActive,
    this.lastSync,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      organizationId: json['organization_id'],
      email: json['email'],
      name: json['name'],
      isVerified: json['is_verified'],
      lastActive: json['last_active'] != null ? DateTime.parse(json['last_active']) : null,
      lastSync: json['last_sync'] != null ? DateTime.parse(json['last_sync']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'email': email,
      'name': name,
      'is_verified': isVerified,
      'last_active': lastActive?.toIso8601String(),
      'last_sync': lastSync?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}