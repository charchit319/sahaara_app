import 'package:flutter/foundation.dart';
import '../config.dart';
import 'mock_data.dart';

/// People + who can access them + pending invites, all from Supabase.
class PeopleStore extends ChangeNotifier {
  bool loading = false;
  String? error;

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      // Attach any invites sent to my email (safe to call every time).
      try {
        await supabase.rpc('claim_my_invites');
      } catch (e) {
        debugPrint('Claiming invites failed: $e');
      }

      final rows = await supabase.from('people').select().order('created_at');
      mockPeople
        ..clear()
        ..addAll(rows.map(Person.fromRow));
      await _loadAccess();
    } catch (e) {
      debugPrint('Loading people failed: $e');
      error = 'Could not load people. Check your connection and try again.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> _loadAccess() async {
    mockAccess.clear();
    mockInvites.clear();
    if (mockPeople.isEmpty) return;

    final ownerOf = {for (final p in mockPeople) p.id: p.ownerId};

    final rows = await supabase
        .from('person_access')
        .select('person_id, user_id, role, level, profiles(full_name, email)');
    for (final r in rows) {
      final personId = r['person_id'] as String;
      final userId = r['user_id'] as String;
      final profile = r['profiles'] as Map<String, dynamic>?;
      final fullName = (profile?['full_name'] as String?)?.trim() ?? '';
      final name = fullName.isNotEmpty ? fullName : ((profile?['email'] as String?) ?? 'Unknown');
      mockAccess.putIfAbsent(personId, () => []).add(AccessMember(
            name,
            roleFromDb(r['role'] as String),
            accessLevelFromDb(r['level'] as String),
            isOwner: ownerOf[personId] == userId,
            userId: userId,
          ));
    }
    for (final list in mockAccess.values) {
      list.sort((a, b) {
        if (a.isOwner != b.isOwner) return a.isOwner ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    }

    // Pending invites: the database only returns these to the creator.
    final inv = await supabase.from('invites').select().eq('status', 'pending').order('created_at');
    for (final r in inv) {
      final i = Invite.fromRow(r);
      mockInvites.putIfAbsent(i.personId, () => []).add(i);
    }
  }

  Future<void> _reloadAccess() async {
    await _loadAccess();
    notifyListeners();
  }

  // ───────── people ─────────
  Future<void> add({required String name, required String relation, int? age}) async {
    final row = await supabase
        .from('people')
        .insert({
          'name': name,
          'relation': relation.isEmpty ? null : relation,
          'age': age,
        })
        .select()
        .single();
    mockPeople.add(Person.fromRow(row));
    await _loadAccess(); // the database trigger just gave you full access
    notifyListeners();
  }

  // ───────── access (only the creator can do these; the database enforces it) ─────────
  Future<void> invite({
    required String personId,
    required String email,
    required String role, // Caregiver, Family, Doctor, Self
    required AccessLevel level,
  }) async {
    await supabase.from('invites').insert({
      'person_id': personId,
      'email': email.trim().toLowerCase(),
      'role': role.toLowerCase(),
      'level': level.db,
    });
    await _reloadAccess();
  }

  Future<void> cancelInvite(String inviteId) async {
    await supabase.from('invites').delete().eq('id', inviteId);
    await _reloadAccess();
  }

  Future<void> removeMember(String personId, String userId) async {
    final res = await supabase
        .from('person_access')
        .delete()
        .eq('person_id', personId)
        .eq('user_id', userId)
        .select();
    if (res.isEmpty) throw Exception('Not allowed'); // blocked by the security rules
    await _reloadAccess();
  }

  Future<void> changeLevel(String personId, String userId, AccessLevel level) async {
    final res = await supabase
        .from('person_access')
        .update({'level': level.db})
        .eq('person_id', personId)
        .eq('user_id', userId)
        .select();
    if (res.isEmpty) throw Exception('Not allowed');
    await _reloadAccess();
  }

  /// Call on log out so the next account never sees this one's data.
  void clear() {
    mockPeople.clear();
    mockAppointments.clear();
    mockRecords.clear();
    mockMedications.clear();
    mockAccess.clear();
    mockInvites.clear();
    mockDocuments.clear();
    mockScans.clear();
    error = null;
    loading = false;
    notifyListeners();
  }
}

final peopleStore = PeopleStore();