/// Dummy data for the prototype. Replace with API/Supabase models later.
class Appointment {
  final int id;
  final DateTime dateTime;
  final String doctor;
  final String institution;
  final String problem;
  final String? prescription;
  const Appointment(this.id, this.dateTime, this.doctor, this.institution, this.problem,
      [this.prescription]);

  bool get isUpcoming => dateTime.isAfter(DateTime.now());
}

class MedicalRecord {
  final int id;
  final DateTime date;
  final String diagnosis;
  final String treatment;
  final String physician;
  final String? prescription;
  const MedicalRecord(this.id, this.date, this.diagnosis, this.treatment, this.physician,
      [this.prescription]);
}

final _now = DateTime.now();

final List<Appointment> mockAppointments = [
  Appointment(1, _now.add(const Duration(days: 3, hours: 2)), 'Dr. Anika Rahman',
      'Square Hospital, Dhaka', 'Routine blood pressure check-up'),
  Appointment(2, _now.add(const Duration(days: 11)), 'Dr. Imran Hossain',
      'United Medical College Hospital', 'Knee pain follow-up',
      'Physiotherapy twice a week'),
  Appointment(3, _now.subtract(const Duration(days: 14)), 'Dr. Farhana Kabir',
      'Labaid Specialized Hospital', 'Diabetes review', 'Metformin 500mg — after meals'),
  Appointment(4, _now.subtract(const Duration(days: 60)), 'Dr. Anika Rahman',
      'Square Hospital, Dhaka', 'Seasonal flu and cough'),
];

final List<MedicalRecord> mockRecords = [
  MedicalRecord(1, DateTime(2026, 8, 2), 'Type 2 Diabetes — controlled',
      'Diet management and regular glucose monitoring', 'Dr. Farhana Kabir',
      'Metformin 500mg — after meals'),
  MedicalRecord(2, DateTime(2026, 5, 18), 'Hypertension (Stage 1)',
      'Low-salt diet, daily walk, medication', 'Dr. Anika Rahman',
      'Amlodipine 5mg — once daily, morning'),
  MedicalRecord(3, DateTime(2026, 1, 9), 'Osteoarthritis — left knee',
      'Physiotherapy and joint-support exercises', 'Dr. Imran Hossain'),
];

// ───────── Dashboard demo data ─────────
const String mockUserName = 'Ayesha';

class Patient {
  final int id;
  final String name;
  final String relation;
  final int age;
  const Patient(this.id, this.name, this.relation, this.age);
}

const List<Patient> mockPatients = [
  Patient(1, 'Abbu', 'Father', 74),
  Patient(2, 'Ammu', 'Mother', 70),
  Patient(3, 'Dadu', 'Grandfather', 86),
];

class Medication {
  final String name;
  final String dose;
  final String time;
  const Medication(this.name, this.dose, this.time);
}

const List<Medication> mockMedications = [
  Medication('Metformin', '500mg · after breakfast', '8:00 AM'),
  Medication('Amlodipine', '5mg · once daily', '9:00 AM'),
  Medication('Calcium + Vitamin D', '1 tablet', '1:30 PM'),
  Medication('Metformin', '500mg · after dinner', '8:30 PM'),
];
