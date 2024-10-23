import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/organization.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> createPendingOrganization() async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');

  // First check if user already has an organization
  final userResponse = await _supabase
      .from('users')
      .select('organization_id')
      .eq('id', userId)
      .single();

  String organizationId;

  if (userResponse['organization_id'] != null) {
    // Use existing organization
    organizationId = userResponse['organization_id'];
  } else {
    // Create new organization with admin user in users array
    final orgResponse = await _supabase
        .from('organization')
        .insert({
          'owner_id': userId,
          'subscription_status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    organizationId = orgResponse['id'];

    // Update user's organization_id
    await _supabase
        .from('users')
        .update({'organization_id': organizationId})
        .eq('id', userId);
  }

  return organizationId;
}

Future<bool> checkOrganizationStatus(String organizationId) async {
  final response = await _supabase
      .from('organization')
      .select('stripe_subscription_id')
      .eq('id', organizationId)
      .single();
  
  return response['stripe_subscription_id'] != null;
}

  Future<Organization> getOrganization(String organizationId) async {
    final response = await _supabase
        .from('organization')
        .select()
        .eq('id', organizationId)
        .single();

    if (response.isEmpty) {
      throw Exception('Failed to fetch organization');
    }

    return Organization.fromJson(response);
  }

  Future<void> joinOrganization(String organizationId) async {
    final user = _supabase.auth.currentUser;
    final userEmail = _supabase.auth.currentUser?.email;
    if (user == null || userEmail == null) {
      throw Exception('User not authenticated');
    }

    // Check if organization exists
    final orgResponse = await _supabase
        .from('organization')
        .select()
        .eq('id', organizationId)
        .single();

    if (orgResponse.isEmpty) {
      throw Exception('Organization not found');
    }

    final organization = Organization.fromJson(orgResponse);

    // Check if user is invited
    if (!organization.userInvites.contains(userEmail)) {
      throw Exception('User not invited to this organization');
    }

    // Add user to org_member table
    await _supabase.from('org_member').insert({
      'id': user.id,
      'organization_id': organizationId,
      'role': 'member',
      'joined_at': DateTime.now().toIso8601String(),
    });

    // Update users table
    final userResponse = await _supabase
        .from('users')
        .update({'organization_id': organizationId}).eq('id', user.id);

    if (userResponse.error != null) {
      throw Exception(
          'Failed to join organization: ${userResponse.error!.message}');
    }

    // Remove user from user_invites
    final updatedInvites =
        organization.userInvites.where((email) => email != userEmail).toList();
    await _supabase
        .from('organization')
        .update({'user_invites': updatedInvites}).eq('id', organizationId);
  }

  Future<Organization> createOrganization(Organization organization) async {
    final response =
        await _supabase.from('organization').insert(organization.toJson());

    if (response.isEmpty) {
      throw Exception(
          'Failed to create organization: ${response.error!.message}');
    }

    return Organization.fromJson(response);
  }

  Future<void> updateOrganization(Organization organization) async {
    final response = await _supabase
        .from('organization')
        .update(organization.toJson())
        .eq('id', organization.id);

    if (response.isEmpty) {
      throw Exception(
          'Failed to update organization: ${response.error!.message}');
    }
  }

  Future<void> inviteUserToOrganization(
      String organizationId, String email) async {
    final organization = await getOrganization(organizationId);
    final updatedInvites = [...organization.userInvites, email];

    final response = await _supabase
        .from('organization')
        .update({'user_invites': updatedInvites}).eq('id', organizationId);

    if (response.isEmpty) {
      throw Exception('Failed to invite user: ${response.error!.message}');
    }
  }

  Future<void> acceptOrganizationInvite(
      String organizationId, String userId) async {
    final organization = await getOrganization(organizationId);
    final updatedUsers = [...organization.users, userId];
    final updatedInvites =
        organization.userInvites.where((email) => email != userId).toList();

    final response = await _supabase.from('organization').update({
      'users': updatedUsers,
      'user_invites': updatedInvites,
    }).eq('id', organizationId);

    if (response.isEmpty) {
      throw Exception('Failed to accept invite: ${response.error!.message}');
    }

    // Update user's organization_id
    final userResponse = await _supabase
        .from('users')
        .update({'organization_id': organizationId}).eq('id', userId);

    if (userResponse.isEmpty) {
      throw Exception(
          'Failed to update user organization: ${userResponse.error!.message}');
    }
  }
}
