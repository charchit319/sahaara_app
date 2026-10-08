import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_text_field.dart';
import '../widgets/picker_field.dart';
import '../widgets/pill_button.dart';
import '../data/care_store.dart';

/// Opens the "Add medical record" form for one person.
Future<void> showAddRecordSheet(
  BuildContext context,
  String personId,
  VoidCallback onSaved, {
  MedicalRecord? existing,
}) {
  return showAppSheet<void>(
    context,
    title: existing == null ? 'Add medical record' : 'Edit medical record',
    child: _AddRecordForm(
      personId: personId,
      onSaved: onSaved,
      existing: existing,
    ),
  );
}

class _AddRecordForm extends StatefulWidget {
  final String personId;
  final VoidCallback onSaved;
  final MedicalRecord? existing;
  const _AddRecordForm({required this.personId, required this.onSaved, this.existing});

  @override
  State<_AddRecordForm> createState() => _AddRecordFormState();
}

class _AddRecordFormState extends State<_AddRecordForm> {
  final _diagnosis = TextEditingController();
  final _physician = TextEditingController();
  final _treatment = TextEditingController();
  final _prescription = TextEditingController();
  DateTime _date = DateTime.now();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _diagnosis.dispose();
    _physician.dispose();
    _treatment.dispose();
    _prescription.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 40),
      lastDate: now, // a record describes something that already happened
    );
    if (picked != null) setState(() => _date = picked);
  }

    Future<void> _save() async {
    if (_diagnosis.text.trim().isEmpty || _physician.text.trim().isEmpty) {
      setState(() => _error = 'Please add the diagnosis and the physician.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await recordsStore.save(
        id: widget.existing?.id,
        personId: widget.personId,
        date: _date,
        diagnosis: _diagnosis.text.trim(),
        physician: _physician.text.trim(),
        treatment: _treatment.text.trim(),
        prescription: _prescription.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      debugPrint('Saving record failed: $e');
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
            label: 'Diagnosis (e.g. Hypertension)',
            icon: Icons.monitor_heart_outlined,
            controller: _diagnosis),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Physician',
            icon: Icons.person_outline_rounded,
            controller: _physician),
        const SizedBox(height: 12),
        PickerField(
          icon: Icons.calendar_today_rounded,
          label: 'Pick a date',
          value: DateFormat('MMM d, y').format(_date),
          onTap: _pickDate,
        ),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Treatment (optional)',
            icon: Icons.healing_rounded,
            controller: _treatment,
            maxLines: 3),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Prescription (optional)',
            icon: Icons.medication_outlined,
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
              : (widget.existing == null ? 'SAVE RECORD' : 'SAVE CHANGES'),
          icon: Icons.check_rounded,
          onPressed: _saving ? () {} : _save,
        ),      ],
    );
  }
}