import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/organization.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

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
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('users')
        .update({'organization_id': organizationId})
        .eq('id', user.id);

    if (response.error != null) {
      throw Exception('Failed to join organization: ${response.error!.message}');
    }
  }

  Future<Organization> createOrganization(Organization organization) async {
    final response = await _supabase
        .from('organization')
        .insert(organization.toJson());
    
    if (response.isEmpty) {
      throw Exception('Failed to create organization: ${response.error!.message}');
    }
    
    return Organization.fromJson(response);
  }

  Future<void> updateOrganization(Organization organization) async {
    final response = await _supabase
        .from('organization')
        .update(organization.toJson())
        .eq('id', organization.id);
    
    if (response.isEmpty) {
      throw Exception('Failed to update organization: ${response.error!.message}');
    }
  }

  Future<void> inviteUserToOrganization(String organizationId, String email) async {
    final organization = await getOrganization(organizationId);
    final updatedInvites = [...organization.userInvites, email];
    
    final response = await _supabase
        .from('organization')
        .update({'user_invites': updatedInvites})
        .eq('id', organizationId);
    
    if (response.isEmpty) {
      throw Exception('Failed to invite user: ${response.error!.message}');
    }
  }

  Future<void> acceptOrganizationInvite(String organizationId, String userId) async {
    final organization = await getOrganization(organizationId);
    final updatedUsers = [...organization.users, userId];
    final updatedInvites = organization.userInvites.where((email) => email != userId).toList();
    
    final response = await _supabase
        .from('organization')
        .update({
          'users': updatedUsers,
          'user_invites': updatedInvites,
        })
        .eq('id', organizationId);
    
    if (response.isEmpty) {
      throw Exception('Failed to accept invite: ${response.error!.message}');
    }

    // Update user's organization_id
    final userResponse = await _supabase
        .from('users')
        .update({'organization_id': organizationId})
        .eq('id', userId);

    if (userResponse.isEmpty) {
      throw Exception('Failed to update user organization: ${userResponse.error!.message}');
    }
  }
}