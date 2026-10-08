import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_text_field.dart';
import '../widgets/picker_field.dart';
import '../widgets/pill_button.dart';
import '../data/care_store.dart';

/// Add a visit, or edit one when [existing] is given.
Future<void> showAddVisitSheet(BuildContext context, String personId, VoidCallback onSaved,
    {Appointment? existing}) {
  return showAppSheet<void>(
    context,
    title: existing == null ? 'Add hospital visit' : 'Edit hospital visit',
    child: _AddVisitForm(personId: personId, onSaved: onSaved, existing: existing),
  );
}

class _AddVisitForm extends StatefulWidget {
  final String personId;
  final VoidCallback onSaved;
  final Appointment? existing;
  const _AddVisitForm({required this.personId, required this.onSaved, this.existing});

  @override
  State<_AddVisitForm> createState() => _AddVisitFormState();
}

class _AddVisitFormState extends State<_AddVisitForm> {
  final _doctor = TextEditingController();
  final _institution = TextEditingController();
  final _reason = TextEditingController();
  final _prescription = TextEditingController();
  DateTime? _date;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _doctor.text = e.doctor;
      _institution.text = e.institution == 'Not specified' ? '' : e.institution;
      _reason.text = e.problem;
      _prescription.text = e.prescription ?? '';
      _date = e.dateTime;
      _time = TimeOfDay.fromDateTime(e.dateTime);
    }
  }

  @override
  void dispose() {
    _doctor.dispose();
    _institution.dispose();
    _reason.dispose();
    _prescription.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

    Future<void> _save() async {
    if (_doctor.text.trim().isEmpty || _reason.text.trim().isEmpty || _date == null) {
      setState(() => _error = 'Please add the doctor, the reason and a date.');
      return;
    }
    final d = _date!;
    final when = DateTime(d.year, d.month, d.day, _time.hour, _time.minute);

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await visitsStore.save(
        id: widget.existing?.id,
        personId: widget.personId,
        when: when,
        doctor: _doctor.text.trim(),
        institution: _institution.text.trim(),
        reason: _reason.text.trim(),
        prescription: _prescription.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      debugPrint('Saving visit failed: $e');
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save. Check your connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
            label: 'Doctor (e.g. Dr. Anika Rahman)',
            icon: Icons.person_outline_rounded,
            controller: _doctor),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Hospital / clinic',
            icon: Icons.local_hospital_outlined,
            controller: _institution),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Reason for visit',
            icon: Icons.medical_information_outlined,
            controller: _reason,
            maxLines: 2),
        const SizedBox(height: 12),
        PickerField(
          icon: Icons.calendar_today_rounded,
          label: 'Pick a date',
          value: _date == null ? null : DateFormat('EEE, MMM d, y').format(_date!),
          onTap: _pickDate,
        ),
        const SizedBox(height: 12),
        PickerField(
          icon: Icons.access_time_rounded,
          label: 'Pick a time',
          value: _time.format(context),
          onTap: _pickTime,
        ),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Prescription / notes (optional)',
            icon: Icons.receipt_long_rounded,
            controller: _prescription,
            maxLines: 2),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: AppTheme.body(13, color: Colors.red.shade700)),
        ],
        const SizedBox(height: 20),
                PillButton(
          label: _saving
              ? 'SAVING…'
              : (widget.existing == null ? 'SAVE VISIT' : 'SAVE CHANGES'),
          icon: Icons.check_rounded,
          onPressed: _saving ? () {} : _save,
        ),
      ],
    );
  }
}