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
          .update({'organization_id': organizationId}).eq('id', userId);
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

  Future<Organization> joinOrganization(String organizationId) async {
  final user = _supabase.auth.currentUser;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  try {
    // Get organization and check if it exists
    final orgResponse = await _supabase
        .from('organization')
        .select()
        .eq('id', organizationId)
        .single();

    if (orgResponse == null) {
      throw Exception('Organization not found');
    }

    // Check if user's email is in user_invites array
    final userInvites = List<String>.from(orgResponse['user_invites'] ?? []);
    if (!userInvites.contains(user.email)) {
      throw Exception('No invitation found for this email address');
    }

    // Get user's name from users table
    final userResponse = await _supabase
        .from('users')
        .select('name')
        .eq('id', user.id)
        .single();

    // Create new org_member object with proper structure
    final newMember = {
      'id': user.id,
      'name': userResponse['name'],
      'role': 'member',
      'joined_at': DateTime.now().toIso8601String()
    };

    // Get current users array and ensure proper typing
    List<Map<String, dynamic>> currentUsers = [];
    if (orgResponse['users'] != null) {
      currentUsers = (orgResponse['users'] as List)
          .map((user) => Map<String, dynamic>.from(user))
          .toList();
    }

    // Add new member to users array
    currentUsers.add(newMember);

    // Remove user's email from invites array
    userInvites.remove(user.email);

    // Update organization with new users array and updated invites
    final updatedOrgResponse = await _supabase
        .from('organization')
        .update({
          'users': currentUsers,
          'user_invites': userInvites,
        })
        .eq('id', organizationId)
        .select()
        .single();

    // Update user's organization_id
    await _supabase
        .from('users')
        .update({'organization_id': organizationId})
        .eq('id', user.id);

    // Convert response to Organization object using updated model
    return Organization.fromJson(updatedOrgResponse);
  } catch (e) {
    if (e.toString().contains('Row not found')) {
      throw Exception('Organization not found');
    }
    // Log the error for debugging
    print('Error in joinOrganization: $e');
    rethrow;
  }
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

  Future<Organization> updateOrganizationDetails({
    required String name,
    required String businessType,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('organization')
        .update({
          'name': name,
          'business_type': businessType,
        })
        .eq('owner_id', userId)
        .select()
        .single();

    return Organization.fromJson(response);
  }

  Future<Organization> inviteUserToOrganization(String email) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final orgResponse = await _supabase
        .from('organization')
        .select()
        .eq('owner_id', userId)
        .single();

    final currentInvites = List<String>.from(orgResponse['user_invites'] ?? []);
    currentInvites.add(email);

    final response = await _supabase
        .from('organization')
        .update({
          'user_invites': currentInvites,
        })
        .eq('owner_id', userId)
        .select()
        .single();

    return Organization.fromJson(response);
  }

  // Future<void> inviteUserToOrganization(
  //     String organizationId, String email) async {
  //   final organization = await getOrganization(organizationId);
  //   final updatedInvites = [...organization.userInvites, email];

  //   final response = await _supabase
  //       .from('organization')
  //       .update({'user_invites': updatedInvites}).eq('id', organizationId);

  //   if (response.isEmpty) {
  //     throw Exception('Failed to invite user: ${response.error!.message}');
  //   }
  // }

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
