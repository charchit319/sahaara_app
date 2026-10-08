import 'package:flutter/material.dart';

/// In-memory stand-ins for the database. They start EMPTY, so the app shows
/// empty states until data is added. Next step: replace each list with Supabase.

// ───────── People (one record per person) ─────────
class Person {
  final String id; // uuid from the database
  final String name;
  final String relation;
  final int? age;
  const Person(this.id, this.name, this.relation, this.age);

  factory Person.fromRow(Map<String, dynamic> row) => Person(
        row['id'] as String,
        row['name'] as String,
        (row['relation'] as String?) ?? '',
        row['age'] as int?,
      );

  /// "Father · 74 yrs" (skips whatever is missing)
  String get subtitle => [
        if (relation.isNotEmpty) relation,
        if (age != null) '$age yrs',
      ].join(' · ');
}

final List<Person> mockPeople = [];

String personName(String id) => mockPeople
    .firstWhere((p) => p.id == id, orElse: () => const Person('', 'Unknown', '', null))
    .name;

// ───────── Hospital visits ─────────
class Appointment {
  final String id; // uuid from the database
  final String personId;
  final DateTime dateTime;
  final String doctor;
  final String institution;
  final String problem;
  final String? prescription;
  const Appointment(this.id, this.personId, this.dateTime, this.doctor, this.institution,
      this.problem,
      [this.prescription]);

  factory Appointment.fromRow(Map<String, dynamic> r) => Appointment(
        r['id'] as String,
        r['person_id'] as String,
        DateTime.parse(r['visit_at'] as String).toLocal(),
        r['doctor'] as String,
        (r['institution'] as String?) ?? 'Not specified',
        r['reason'] as String,
        r['prescription'] as String?,
      );

  bool get isUpcoming => dateTime.isAfter(DateTime.now());
}

final List<Appointment> mockAppointments = [];

// ───────── Medical history ─────────
class MedicalRecord {
  final String id; // uuid from the database
  final String personId;
  final DateTime date;
  final String diagnosis;
  final String treatment;
  final String physician;
  final String? prescription;
  const MedicalRecord(this.id, this.personId, this.date, this.diagnosis, this.treatment,
      this.physician,
      [this.prescription]);

  factory MedicalRecord.fromRow(Map<String, dynamic> r) => MedicalRecord(
        r['id'] as String,
        r['person_id'] as String,
        DateTime.parse(r['recorded_on'] as String),
        r['diagnosis'] as String,
        (r['treatment'] as String?) ?? 'Not specified',
        r['physician'] as String,
        r['prescription'] as String?,
      );
}

final List<MedicalRecord> mockRecords = [];

// ───────── Medication ─────────
class Medication {
  final String personId;
  final String name;
  final String dose;
  final String time;
  const Medication(this.personId, this.name, this.dose, this.time);
}

final List<Medication> mockMedications = [];

// ───────── Access sharing ─────────
enum AccessLevel { full, viewOnly, limited }

extension AccessLevelX on AccessLevel {
  String get label => switch (this) {
        AccessLevel.full => 'Full access',
        AccessLevel.viewOnly => 'View only',
        AccessLevel.limited => 'Limited',
      };
  String get hint => switch (this) {
        AccessLevel.full => 'Can view and add records, visits and documents',
        AccessLevel.viewOnly => 'Can see everything, but cannot change anything',
        AccessLevel.limited => 'Can only see visits and medication',
      };
}

class AccessMember {
  final String name;
  final String role; // Self, Caregiver, Family, Doctor
  final AccessLevel level;
  final bool isOwner;
  const AccessMember(this.name, this.role, this.level, {this.isOwner = false});
}

/// personId -> people who can open that person's record.
final Map<String, List<AccessMember>> mockAccess = {};
// ───────── Documents (paper) ─────────
enum DocKind { prescription, labReport, insurance, idCard, other }

extension DocKindX on DocKind {
  String get label => switch (this) {
        DocKind.prescription => 'Prescription',
        DocKind.labReport => 'Lab report',
        DocKind.insurance => 'Insurance',
        DocKind.idCard => 'ID card',
        DocKind.other => 'Other',
      };
  IconData get icon => switch (this) {
        DocKind.prescription => Icons.receipt_long_rounded,
        DocKind.labReport => Icons.science_rounded,
        DocKind.insurance => Icons.shield_rounded,
        DocKind.idCard => Icons.badge_rounded,
        DocKind.other => Icons.description_rounded,
      };
}

class DocumentItem {
  final int id;
  final String personId;
  final String title;
  final DateTime date;
  final DocKind kind;
  const DocumentItem(this.id, this.personId, this.title, this.date, this.kind);
}

// ───────── X-rays & scans (imaging), kept separate from documents ─────────
enum ScanKind { xray, mri, ct, ultrasound }

extension ScanKindX on ScanKind {
  String get label => switch (this) {
        ScanKind.xray => 'X-ray',
        ScanKind.mri => 'MRI',
        ScanKind.ct => 'CT scan',
        ScanKind.ultrasound => 'Ultrasound',
      };
  IconData get icon => switch (this) {
        ScanKind.xray => Icons.accessibility_new_rounded,
        ScanKind.mri => Icons.psychology_alt_rounded,
        ScanKind.ct => Icons.donut_large_rounded,
        ScanKind.ultrasound => Icons.graphic_eq_rounded,
      };
}

class ScanItem {
  final int id;
  final String personId;
  final String title;
  final String bodyPart;
  final ScanKind kind;
  final DateTime date;
  final String facility;
  const ScanItem(this.id, this.personId, this.title, this.bodyPart, this.kind, this.date,
      this.facility);
}

final List<DocumentItem> mockDocuments = [];
final List<ScanItem> mockScans = [];