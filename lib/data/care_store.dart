import 'package:flutter/foundation.dart';
import '../config.dart';
import 'mock_data.dart';

String? _nullIfEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

/// Local date as yyyy-MM-dd (what a Postgres `date` column expects).
String _dateOnly(DateTime d) => d.toIso8601String().substring(0, 10);

// ───────────────────────── Visits ─────────────────────────
class VisitsStore extends ChangeNotifier {
  bool loading = false;
  String? error;

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final rows = await supabase.from('visits').select().order('visit_at');
      mockAppointments
        ..clear()
        ..addAll(rows.map(Appointment.fromRow));
    } catch (e) {
      debugPrint('Loading visits failed: $e');
      error = 'Could not load visits. Check your connection and try again.';
    }
    loading = false;
    notifyListeners();
  }

  /// Creates a visit, or updates it when [id] is given.
  Future<void> save({
    String? id,
    required String personId,
    required DateTime when,
    required String doctor,
    required String institution,
    required String reason,
    String? prescription,
  }) async {
    final data = {
      'person_id': personId,
      'visit_at': when.toUtc().toIso8601String(),
      'doctor': doctor,
      'institution': _nullIfEmpty(institution),
      'reason': reason,
      'prescription': _nullIfEmpty(prescription),
    };
    final row = id == null
        ? await supabase.from('visits').insert(data).select().single()
        : await supabase.from('visits').update(data).eq('id', id).select().single();

    final item = Appointment.fromRow(row);
    final i = mockAppointments.indexWhere((a) => a.id == item.id);
    if (i >= 0) {
      mockAppointments[i] = item;
    } else {
      mockAppointments.add(item);
    }
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await supabase.from('visits').delete().eq('id', id);
    mockAppointments.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}

// ───────────────────────── Medical records ─────────────────────────
class RecordsStore extends ChangeNotifier {
  bool loading = false;
  String? error;

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final rows =
          await supabase.from('medical_records').select().order('recorded_on', ascending: false);
      mockRecords
        ..clear()
        ..addAll(rows.map(MedicalRecord.fromRow));
    } catch (e) {
      debugPrint('Loading records failed: $e');
      error = 'Could not load medical records. Check your connection and try again.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> save({
    String? id,
    required String personId,
    required DateTime date,
    required String diagnosis,
    required String physician,
    required String treatment,
    String? prescription,
  }) async {
    final data = {
      'person_id': personId,
      'recorded_on': _dateOnly(date),
      'diagnosis': diagnosis,
      'physician': physician,
      'treatment': _nullIfEmpty(treatment),
      'prescription': _nullIfEmpty(prescription),
    };
    final row = id == null
        ? await supabase.from('medical_records').insert(data).select().single()
        : await supabase.from('medical_records').update(data).eq('id', id).select().single();

    final item = MedicalRecord.fromRow(row);
    final i = mockRecords.indexWhere((r) => r.id == item.id);
    if (i >= 0) {
      mockRecords[i] = item;
    } else {
      mockRecords.add(item);
    }
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await supabase.from('medical_records').delete().eq('id', id);
    mockRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}

final visitsStore = VisitsStore();
final recordsStore = RecordsStore();