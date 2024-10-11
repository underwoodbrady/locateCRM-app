import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationModel {
  final String id;
  final String ownerId;
  final String name;
  final List<String> users;
  final List<String> userInvites;
  final int plan;
  final bool isPro;
  final String businessType;
  final String? stripeCustomerId;
  final DateTime createdAt;
  final DateTime? trialExpiration;

  OrganizationModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.users,
    required this.userInvites,
    required this.plan,
    required this.isPro,
    required this.businessType,
    this.stripeCustomerId,
    required this.createdAt,
    this.trialExpiration,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      users: List<String>.from(json['users']),
      userInvites: List<String>.from(json['user_invites']),
      plan: json['plan'],
      isPro: json['is_pro'],
      businessType: json['business_type'],
      stripeCustomerId: json['stripe_customer_id'],
      createdAt: DateTime.parse(json['created_at']),
      trialExpiration: json['trial_expiration'] != null ? DateTime.parse(json['trial_expiration']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'users': users,
      'user_invites': userInvites,
      'plan': plan,
      'is_pro': isPro,
      'business_type': businessType,
      'stripe_customer_id': stripeCustomerId,
      'created_at': createdAt.toIso8601String(),
      'trial_expiration': trialExpiration?.toIso8601String(),
    };
  }
}