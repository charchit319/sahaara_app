import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_data.dart';
import '../data/people_store.dart';
import '../data/permissions.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_text_field.dart';
import '../widgets/card_actions.dart';
import '../widgets/glass_card.dart';
import '../widgets/pill_button.dart';

/// Who can open this person's record. Only the creator of the record can change it.
class AccessSection extends StatelessWidget {
  final Person person;
  const AccessSection({super.key, required this.person});

  void _snack(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text, style: AppTheme.body(14, color: AppColors.sand))));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: peopleStore,
      builder: (context, _) {
        final iAmOwner = isOwnerOf(person);
        final members = mockAccess[person.id] ?? <AccessMember>[];
        final invites = mockInvites[person.id] ?? <Invite>[];
        final owners = members.where((m) => m.isOwner).toList();
        final ownerName =
            owners.isEmpty ? 'the person who created this record' : owners.first.name;

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration:
                  BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(24)),
              child: Row(children: [
                const Icon(Icons.lock_person_rounded, color: AppColors.maroon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    iAmOwner
                        ? 'You created this record, so only you can invite people, change what they can do, or remove them. Your own access can never be removed.'
                        : 'Only $ownerName, who created this record, can change who has access.',
                    style: AppTheme.body(13.5, color: AppColors.brown),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            if (iAmOwner) ...[
              PillButton(
                  label: 'INVITE SOMEONE',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => _invite(context)),
              const SizedBox(height: 16),
            ],
            ...members.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _memberTile(context, m, iAmOwner),
                )),
            if (iAmOwner && invites.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('PENDING INVITES', style: AppTheme.label()),
              const SizedBox(height: 10),
              ...invites.map((i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _inviteTile(context, i),
                  )),
            ],
          ],
        );
      },
    );
  }

  // ───────── tiles ─────────
  Widget _pill(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.maroon.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(t,
            style: AppTheme.body(11, color: AppColors.maroon, weight: FontWeight.w700)),
      );

  Widget _memberTile(BuildContext context, AccessMember m, bool iAmOwner) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.maroon.withOpacity(0.12),
            child: Text(m.name.isEmpty ? '?' : m.name[0], style: AppTheme.heading(18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(14.5, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _pill(m.isOwner ? 'Creator' : roleLabel(m.role)),
                    Text(m.level.label, style: AppTheme.body(12, color: AppColors.tan)),
                  ],
                ),
              ],
            ),
          ),
          if (m.isOwner)
            const Tooltip(
              message: 'The creator always keeps access',
              child: Icon(Icons.lock_rounded, color: AppColors.tan, size: 20),
            )
          else if (iAmOwner && m.userId != null) ...[
            IconButton(
              tooltip: 'Change what they can do',
              onPressed: () => _editLevel(context, m),
              icon: const Icon(Icons.tune_rounded, color: AppColors.brown),
            ),
            IconButton(
              tooltip: 'Remove access',
              onPressed: () => _remove(context, m),
              icon: Icon(Icons.person_remove_rounded, color: Colors.red.shade700),
            ),
          ],
        ],
      ),
    );
  }

  Widget _inviteTile(BuildContext context, Invite i) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.mark_email_unread_rounded, color: AppColors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(14, weight: FontWeight.w700)),
                Text('${roleLabel(i.role)} · ${i.level.label} · waiting for them to sign in',
                    style: AppTheme.body(12, color: AppColors.tan)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cancel invite',
            onPressed: () async {
              try {
                await peopleStore.cancelInvite(i.id);
              } catch (e) {
                debugPrint('Cancel invite failed: $e');
                if (context.mounted) _snack(context, 'Could not cancel the invite.');
              }
            },
            icon: const Icon(Icons.close_rounded, color: AppColors.brown),
          ),
        ],
      ),
    );
  }

  // ───────── actions ─────────
  Future<void> _remove(BuildContext context, AccessMember m) async {
    if (!await confirmDelete(context, "${m.name}'s access")) return;
    try {
      await peopleStore.removeMember(person.id, m.userId!);
      if (context.mounted) _snack(context, '${m.name} no longer has access');
    } catch (e) {
      debugPrint('Remove access failed: $e');
      if (context.mounted) _snack(context, 'Could not remove access. Please try again.');
    }
  }

  void _editLevel(BuildContext context, AccessMember m) {
    showAppSheet<void>(
      context,
      title: 'What can ${m.name} do?',
      child: Column(
        children: AccessLevel.values
            .map((l) => _LevelOption(
                  level: l,
                  selected: l == m.level,
                  onTap: () async {
                    try {
                      await peopleStore.changeLevel(person.id, m.userId!, l);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      debugPrint('Change level failed: $e');
                      if (context.mounted) _snack(context, 'Could not change access.');
                    }
                  },
                ))
            .toList(),
      ),
    );
  }

  void _invite(BuildContext context) {
    showAppSheet<void>(
      context,
      title: "Invite to ${person.name}'s record",
      child: _InviteForm(
        personId: person.id,
        onSent: (email) {
          if (context.mounted) _snack(context, 'Invite saved for $email');
        },
      ),
    );
  }
}

// ───────────────────────── pieces ─────────────────────────

class _LevelOption extends StatelessWidget {
  final AccessLevel level;
  final bool selected;
  final VoidCallback onTap;
  const _LevelOption({required this.level, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(selected ? 0.8 : 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.maroon : Colors.white, width: 1.4),
        ),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: AppColors.maroon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level.label, style: AppTheme.body(14.5, weight: FontWeight.w700)),
                Text(level.hint, style: AppTheme.body(12.5, color: AppColors.tan)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _InviteForm extends StatefulWidget {
  final String personId;
  final void Function(String email) onSent;
  const _InviteForm({required this.personId, required this.onSent});

  @override
  State<_InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<_InviteForm> {
  static const _roles = [
    ('Caregiver', 'Caregiver'),
    ('Family', 'Family'),
    ('Doctor', 'Doctor'),
    ('Themselves', 'Self'),
  ];

  final _email = TextEditingController();
  String _role = 'Family';
  AccessLevel _level = AccessLevel.viewOnly;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await peopleStore.invite(
          personId: widget.personId, email: email, role: _role, level: _level);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSent(email);
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.code == '23505'
              ? 'That email already has a pending invite.'
              : 'Could not send the invite. Please try again.';
        });
      }
    } catch (e) {
      debugPrint('Invite failed: $e');
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not send the invite. Check your connection and try again.';
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
            label: 'Their email address',
            icon: Icons.alternate_email_rounded,
            controller: _email,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 6),
        Text(
            'They get access when they sign up or log in to Sahaara with this exact email.',
            style: AppTheme.body(12.5, color: AppColors.tan)),
        const SizedBox(height: 16),
        Text('WHO ARE THEY?', style: AppTheme.label()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _roles.map((r) {
            final sel = r.$2 == _role;
            return GestureDetector(
              onTap: () => setState(() => _role = r.$2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.maroon : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(r.$1,
                    style: AppTheme.body(13,
                        color: sel ? AppColors.sand : AppColors.text,
                        weight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
        if (_role == 'Self') ...[
          const SizedBox(height: 8),
          Text('Choose this when the person has their own account and wants to see their own record.',
              style: AppTheme.body(12.5, color: AppColors.tan)),
        ],
        const SizedBox(height: 16),
        Text('WHAT CAN THEY DO?', style: AppTheme.label()),
        const SizedBox(height: 8),
        ...AccessLevel.values.map((l) => _LevelOption(
              level: l,
              selected: l == _level,
              onTap: () => setState(() => _level = l),
            )),
        if (_error != null) ...[
          const SizedBox(height: 4),
          Text(_error!, style: AppTheme.body(13, color: Colors.red.shade700)),
        ],
        const SizedBox(height: 14),
        PillButton(
          label: _saving ? 'SENDING…' : 'SEND INVITE',
          icon: Icons.send_rounded,
          onPressed: _saving ? () {} : _send,
        ),
      ],
    );
  }
}