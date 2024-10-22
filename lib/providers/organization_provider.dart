import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/organization.dart';
import '../services/supabase_service.dart';

final organizationProvider = StateNotifierProvider<OrganizationNotifier, AsyncValue<Organization?>>((ref) {
  return OrganizationNotifier(SupabaseService());
});

class OrganizationNotifier extends StateNotifier<AsyncValue<Organization?>> {
  final SupabaseService _supabaseService;

  OrganizationNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> fetchOrganization(String organizationId) async {
    state = const AsyncValue.loading();
    try {
      final organization = await _supabaseService.getOrganization(organizationId);
      state = AsyncValue.data(organization);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createOrganization(Organization organization) async {
    state = const AsyncValue.loading();
    try {
      final createdOrganization = await _supabaseService.createOrganization(organization);
      state = AsyncValue.data(createdOrganization);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}