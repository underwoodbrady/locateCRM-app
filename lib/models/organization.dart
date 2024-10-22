import 'package:flutter/foundation.dart';

class Organization {
  final String id;
  final String ownerId;
  final String name;
  final List<String> users;
  final List<String> userInvites;
  final int plan;
  final bool isPro;
  final String businessType;
  final String? stripeCustomerId;
  final String subscriptionStatus;
  final DateTime subscriptionEndDate;
  final String? stripeSubscriptionId;

  Organization({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.users,
    required this.userInvites,
    required this.plan,
    required this.isPro,
    required this.businessType,
    this.stripeCustomerId,
    required this.subscriptionStatus,
    required this.subscriptionEndDate,
    this.stripeSubscriptionId,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      users: List<String>.from(json['users']),
      userInvites: List<String>.from(json['user_invites']),
      plan: json['plan'],
      isPro: json['is_pro'],
      businessType: json['business_type'],
      stripeCustomerId: json['stripe_customer_id'],
      subscriptionStatus: json['subscription_status'],
      subscriptionEndDate: DateTime.parse(json['subscription_end_date']),
      stripeSubscriptionId: json['stripe_subscription_id'],
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
      'subscription_status': subscriptionStatus,
      'subscription_end_date': subscriptionEndDate.toIso8601String(),
      'stripe_subscription_id': stripeSubscriptionId,
    };
  }
}