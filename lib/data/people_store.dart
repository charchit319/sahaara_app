import 'package:flutter/foundation.dart';
import '../config.dart';
import 'mock_data.dart';

/// Loads and saves people in Supabase. Screens listen to it and rebuild.
/// (mockPeople is kept as the in-memory cache so the other screens still work.)
class PeopleStore extends ChangeNotifier {
  bool loading = false;
  String? error;

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final rows = await supabase.from('people').select().order('created_at');
      mockPeople
        ..clear()
        ..addAll(rows.map(Person.fromRow));
      // Access is still local until the "Access" step: for now you are the caregiver.
      for (final p in mockPeople) {
        mockAccess.putIfAbsent(
            p.id, () => [AccessMember(userName, 'Caregiver', AccessLevel.full)]);
      }
    } catch (e) {
      debugPrint('Loading people failed: $e');
      error = 'Could not load people. Check your connection and try again.';
    }
    loading = false;
    notifyListeners();
  }

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
    final p = Person.fromRow(row);
    mockPeople.add(p);
    mockAccess[p.id] = [AccessMember(userName, 'Caregiver', AccessLevel.full)];
    notifyListeners();
  }

  /// Call on log out so the next account never sees this one's data.
  void clear() {
    mockPeople.clear();
    mockAppointments.clear();
    mockRecords.clear();
    mockMedications.clear();
    mockAccess.clear();
    mockDocuments.clear();
    mockScans.clear();
    error = null;
    loading = false;
    notifyListeners();
  }
}

final peopleStore = PeopleStore();