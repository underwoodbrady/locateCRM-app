import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/organization.dart';

final organizationProvider = StateNotifierProvider<OrganizationNotifier, AsyncValue<OrganizationModel?>>((ref) {
  return OrganizationNotifier(Supabase.instance.client);
});

class OrganizationNotifier extends StateNotifier<AsyncValue<OrganizationModel?>> {
  final SupabaseClient _supabaseClient;

  OrganizationNotifier(this._supabaseClient) : super(const AsyncValue.loading());

  Future<void> fetchOrganization(String organizationId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabaseClient
          .from('organizations')
          .select()
          .eq('id', organizationId)
          .single();
      
      if (response != null) {
        state = AsyncValue.data(OrganizationModel.fromJson(response));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createOrganization({
    required String name,
    required String ownerId,
    required String businessType,
    required int plan,
  }) async {
    state = const AsyncValue.loading();
    try {
      final newOrg = {
        'name': name,
        'owner_id': ownerId,
        'business_type': businessType,
        'plan': plan,
        'is_pro': false,
        'users': [ownerId],
        'user_invites': [],
      };

      final response = await _supabaseClient
          .from('organizations')
          .insert(newOrg)
          .select()
          .single();

      if (response != null) {
        state = AsyncValue.data(OrganizationModel.fromJson(response));
        // Update the user's organization_id
        await _supabaseClient
            .from('users')
            .update({'organization_id': response['id']})
            .eq('id', ownerId);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> joinOrganization({required String userId, required String organizationId}) async {
    state = const AsyncValue.loading();
    try {
      final org = await _supabaseClient
          .from('organizations')
          .select()
          .eq('id', organizationId)
          .single();

      if (org != null) {
        final updatedUsers = [...org['users'], userId];
        await _supabaseClient
            .from('organizations')
            .update({'users': updatedUsers})
            .eq('id', organizationId);

        // Update the user's organization_id
        await _supabaseClient
            .from('users')
            .update({'organization_id': organizationId})
            .eq('id', userId);

        state = AsyncValue.data(OrganizationModel.fromJson(org));
      } else {
        throw Exception('Organization not found');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}