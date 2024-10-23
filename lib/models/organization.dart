class OrgMember {
  final String id;
  final String name;
  final String role;
  final DateTime joinedAt;

  OrgMember({
    required this.id,
    required this.name,
    required this.role,
    required this.joinedAt,
  });

  factory OrgMember.fromJson(Map<String, dynamic> json) {
    return OrgMember(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

class Organization {
  final String id;
  final String ownerId;
  final String name;
  final List<OrgMember> users;
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
      users: (json['users'] as List?)
          ?.map((user) => OrgMember.fromJson(user as Map<String, dynamic>))
          .toList() ?? [],
      userInvites: List<String>.from(json['user_invites'] ?? []),
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
      'users': users.map((user) => user.toJson()).toList(),
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