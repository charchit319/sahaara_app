import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_text_field.dart';
import '../widgets/glass_card.dart';
import '../widgets/pill_button.dart';

/// Who can open this person's record, and what they can do with it.
class AccessSection extends StatefulWidget {
  final Person person;
  final bool readOnly;
  const AccessSection({super.key, required this.person, required this.readOnly});

  @override
  State<AccessSection> createState() => _AccessSectionState();
}

class _AccessSectionState extends State<AccessSection> {
  List<AccessMember> get _members => mockAccess.putIfAbsent(widget.person.id, () => []);

  @override
  Widget build(BuildContext context) {
    final members = _members;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.sand,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(children: [
            const Icon(Icons.lock_person_rounded, color: AppColors.maroon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.readOnly
                    ? 'These are the people who can see your record. Ask your caregiver to change this.'
                    : 'Only the people you invite can open ${widget.person.name}\'s record.',
                style: AppTheme.body(13.5, color: AppColors.brown),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        if (!widget.readOnly) ...[
          PillButton(
              label: 'INVITE SOMEONE',
              icon: Icons.person_add_alt_1_rounded,
              onPressed: _invite),
          const SizedBox(height: 16),
        ],
        ...members.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _memberTile(m),
            )),
      ],
    );
  }

  Widget _memberTile(AccessMember m) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.maroon.withOpacity(0.12),
            child: Text(m.name[0], style: AppTheme.heading(18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: AppTheme.body(14.5, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(children: [
                  _pill(m.isOwner ? 'Owner' : m.role, filled: true),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(m.level.label,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(12, color: AppColors.tan)),
                  ),
                ]),
              ],
            ),
          ),
          if (!widget.readOnly && !m.isOwner)
            IconButton(
              tooltip: 'Remove access',
              onPressed: () {
                setState(() => _members.remove(m));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${m.name} no longer has access',
                        style: AppTheme.body(14, color: AppColors.sand))));
              },
              icon: const Icon(Icons.person_remove_rounded, color: AppColors.brown),
            ),
        ],
      ),
    );
  }

  Widget _pill(String t, {bool filled = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: filled ? AppColors.maroon.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(t,
            style: AppTheme.body(11, color: AppColors.maroon, weight: FontWeight.w700)),
      );

  void _invite() {
    showAppSheet<void>(
      context,
      title: 'Invite to ${widget.person.name}\'s record',
      child: _InviteForm(onSend: (name, role, level) {
        setState(() => _members.add(AccessMember(name, role, level)));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invite sent to $name (prototype)',
                style: AppTheme.body(14, color: AppColors.sand))));
      }),
    );
  }
}

class _InviteForm extends StatefulWidget {
  final void Function(String name, String role, AccessLevel level) onSend;
  const _InviteForm({required this.onSend});

  @override
  State<_InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<_InviteForm> {
  final _name = TextEditingController();
  String _role = 'Family';
  AccessLevel _level = AccessLevel.viewOnly;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
            label: 'Name, email or phone',
            icon: Icons.alternate_email_rounded,
            controller: _name),
        const SizedBox(height: 16),
        Text('ROLE', style: AppTheme.label()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Caregiver', 'Family', 'Doctor'].map((r) {
            final sel = r == _role;
            return GestureDetector(
              onTap: () => setState(() => _role = r),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.maroon : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(r,
                    style: AppTheme.body(13,
                        color: sel ? AppColors.sand : AppColors.text, weight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text('WHAT CAN THEY DO?', style: AppTheme.label()),
        const SizedBox(height: 8),
        ...AccessLevel.values.map((l) {
          final sel = l == _level;
          return GestureDetector(
            onTap: () => setState(() => _level = l),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(sel ? 0.8 : 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? AppColors.maroon : Colors.white, width: 1.4),
              ),
              child: Row(children: [
                Icon(sel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: AppColors.maroon, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.label, style: AppTheme.body(14.5, weight: FontWeight.w700)),
                      Text(l.hint, style: AppTheme.body(12.5, color: AppColors.tan)),
                    ],
                  ),
                ),
              ]),
            ),
          );
        }),
        const SizedBox(height: 10),
        PillButton(
          label: 'SEND INVITE',
          icon: Icons.send_rounded,
          onPressed: () {
            final n = _name.text.trim();
            if (n.isEmpty) return;
            widget.onSend(n, _role, _level);
          },
        ),
      ],
    );
  }
}
