import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_text_field.dart';
import '../widgets/pill_button.dart';
import '../widgets/empty_state.dart';


/// Documents (paper, cream/maroon) and X-rays & scans (dark "lightbox", cool blue)
/// live in the same section but are split by a big switch, look completely
/// different, and have separate add-forms — so they are never mixed up.
class DocumentsSection extends StatefulWidget {
  final String personId;
  final bool readOnly;
  const DocumentsSection({super.key, required this.personId, required this.readOnly});

  @override
  State<DocumentsSection> createState() => _DocumentsSectionState();
}

class _DocumentsSectionState extends State<DocumentsSection> {
  bool _scans = false;

  List<DocumentItem> get _docs =>
      mockDocuments.where((d) => d.personId == widget.personId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  List<ScanItem> get _scanItems =>
      mockScans.where((s) => s.personId == widget.personId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            Expanded(child: _tile(scan: false, label: 'Documents', icon: Icons.description_rounded, count: _docs.length)),
            const SizedBox(width: 12),
            Expanded(child: _tile(scan: true, label: 'X-rays & Scans', icon: Icons.biotech_rounded, count: _scanItems.length)),
          ]),
        ),
        const SizedBox(height: 14),
        if (!widget.readOnly)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
            child: PillButton(
              label: _scans ? 'ADD X-RAY / SCAN' : 'ADD DOCUMENT',
              icon: Icons.add_a_photo_rounded,
              color: _scans ? AppColors.scanDark : null,
              onPressed: _openAdd,
            ),
          ),
        Expanded(child: _scans ? _scanGrid() : _docGrid()),
      ],
    );
  }

  // ───────── switch ─────────
  Widget _tile(
      {required bool scan, required String label, required IconData icon, required int count}) {
    final selected = _scans == scan;
    final Color bg, fg, border;
    if (scan) {
      bg = selected ? AppColors.scanDark : AppColors.scanDark.withOpacity(0.10);
      fg = selected ? Colors.white : AppColors.scanDark;
      border = selected ? AppColors.scanAccent : AppColors.scanDark.withOpacity(0.25);
    } else {
      bg = selected ? AppColors.maroon : Colors.white.withOpacity(0.45);
      fg = selected ? AppColors.sand : AppColors.maroon;
      border = selected ? AppColors.maroon : Colors.white.withOpacity(0.8);
    }
    return GestureDetector(
      onTap: () => setState(() => _scans = scan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: border, width: 1.3),
        ),
        child: Row(children: [
          Icon(icon, color: scan && selected ? AppColors.scanAccent : fg, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(13.5, color: fg, weight: FontWeight.w800)),
                Text('$count item${count == 1 ? '' : 's'}',
                    style: AppTheme.body(11.5, color: fg.withOpacity(0.7))),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ───────── grids ─────────
    Widget _empty(String text, IconData icon) => EmptyState(
        icon: _scans ? Icons.biotech_rounded : Icons.description_rounded,
        title: text,
        message: widget.readOnly
            ? 'Your caregiver has not added any yet.'
            : (_scans
                ? 'Tap "ADD X-RAY / SCAN" above to add a photo of a scan.'
                : 'Tap "ADD DOCUMENT" above to add a photo of a prescription or report.'),
        dark: _scans,
      );

  SliverGridDelegate get _delegate => const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.8,
      );

  Widget _docGrid() {
    final items = _docs;
    if (items.isEmpty) return _empty('No documents yet.', Icons.description_outlined);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
      gridDelegate: _delegate,
      itemCount: items.length,
      itemBuilder: (_, i) => _DocCard(item: items[i], onTap: () => _viewDoc(items[i])),
    );
  }

  Widget _scanGrid() {
    final items = _scanItems;
    if (items.isEmpty) return _empty('No X-rays or scans yet.', Icons.biotech_outlined);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
      gridDelegate: _delegate,
      itemCount: items.length,
      itemBuilder: (_, i) => _ScanCard(item: items[i], onTap: () => _viewScan(items[i])),
    );
  }

  // ───────── sheets ─────────
  void _viewDoc(DocumentItem d) {
    showAppSheet<void>(
      context,
      title: d.title,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16)],
          ),
          child: Center(child: Icon(d.kind.icon, size: 64, color: AppColors.maroon.withOpacity(0.5))),
        ),
        const SizedBox(height: 16),
        _detail('Type', d.kind.label),
        _detail('Added', DateFormat('MMM d, y').format(d.date)),
        const SizedBox(height: 4),
        Text('(Prototype — the real photo will show here.)',
            style: AppTheme.body(12, color: AppColors.tan)),
      ]),
    );
  }

  void _viewScan(ScanItem s) {
    showAppSheet<void>(
      context,
      title: s.title,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const RadialGradient(
                colors: [Color(0xFF2B3644), AppColors.scanDark], radius: 0.9),
          ),
          child: Center(child: Icon(s.kind.icon, size: 84, color: AppColors.scanAccent.withOpacity(0.85))),
        ),
        const SizedBox(height: 16),
        _detail('Scan type', s.kind.label),
        _detail('Body part', s.bodyPart),
        _detail('Facility', s.facility),
        _detail('Date', DateFormat('MMM d, y').format(s.date)),
        const SizedBox(height: 4),
        Text('(Prototype — the real image will show here.)',
            style: AppTheme.body(12, color: AppColors.tan)),
      ]),
    );
  }

  Widget _detail(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          SizedBox(width: 100, child: Text(k.toUpperCase(), style: AppTheme.label())),
          Expanded(child: Text(v, style: AppTheme.body(14.5, weight: FontWeight.w600))),
        ]),
      );

  void _openAdd() {
    final scan = _scans;
    showAppSheet<void>(
      context,
      title: scan ? 'Add X-ray / scan' : 'Add document',
      child: _AddItemForm(
        scan: scan,
        onSave: (title, kindIndex, bodyPart) {
          setState(() {
            final id = DateTime.now().millisecondsSinceEpoch;
            if (scan) {
              final k = ScanKind.values[kindIndex];
              mockScans.add(ScanItem(id, widget.personId, title.isEmpty ? k.label : title,
                  bodyPart.isEmpty ? 'Not specified' : bodyPart, k, DateTime.now(), 'Added by you'));
            } else {
              final k = DocKind.values[kindIndex];
              mockDocuments.add(DocumentItem(
                  id, widget.personId, title.isEmpty ? k.label : title, DateTime.now(), k));
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ───────────────────────── cards ─────────────────────────

class _DocCard extends StatelessWidget {
  final DocumentItem item;
  final VoidCallback onTap;
  const _DocCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.maroon.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "paper" thumbnail with text lines
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cream.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.maroon, shape: BoxShape.circle),
                      child: Icon(item.kind.icon, size: 14, color: AppColors.sand),
                    ),
                    const SizedBox(height: 10),
                    for (final w in [0.9, 0.7, 0.85, 0.5])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: FractionallySizedBox(
                          widthFactor: w,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                                color: AppColors.tan.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body(13.5, weight: FontWeight.w700)),
                  Text('${item.kind.label} · ${DateFormat('MMM d').format(item.date)}',
                      style: AppTheme.body(11.5, color: AppColors.tan)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final ScanItem item;
  final VoidCallback onTap;
  const _ScanCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.scanDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.scanAccent.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // dark "film" thumbnail
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const RadialGradient(
                      colors: [Color(0xFF2B3644), Color(0xFF0E1218)], radius: 0.9),
                ),
                child: Stack(
                  children: [
                    Center(
                        child: Icon(item.kind.icon,
                            size: 46, color: AppColors.scanAccent.withOpacity(0.8))),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.scanAccent.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item.kind.label.toUpperCase(),
                            style: AppTheme.body(9.5, color: AppColors.scanAccent, weight: FontWeight.w800)
                                .copyWith(letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body(13.5, color: Colors.white, weight: FontWeight.w700)),
                  Text('${item.bodyPart} · ${DateFormat('MMM d').format(item.date)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body(11.5, color: AppColors.scanAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── add form ─────────────────────────

class _AddItemForm extends StatefulWidget {
  final bool scan;
  final void Function(String title, int kindIndex, String bodyPart) onSave;
  const _AddItemForm({required this.scan, required this.onSave});

  @override
  State<_AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<_AddItemForm> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  int _kind = 0;
  bool _attached = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scan = widget.scan;
    final accent = scan ? AppColors.scanDark : AppColors.maroon;
    final labels = scan
        ? ScanKind.values.map((k) => k.label).toList()
        : DocKind.values.map((k) => k.label).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // banner so it is obvious which kind of item is being added
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            Icon(scan ? Icons.biotech_rounded : Icons.description_rounded,
                color: scan ? AppColors.scanAccent : AppColors.sand),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                scan
                    ? 'Medical imaging: X-ray, MRI, CT or ultrasound'
                    : 'Paper documents: prescriptions, lab reports, insurance, ID',
                style: AppTheme.body(13, color: Colors.white, weight: FontWeight.w600),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        AppTextField(
            label: scan ? 'Title (e.g. Chest X-ray)' : 'Title (e.g. Blood test report)',
            icon: Icons.title_rounded,
            controller: _title),
        if (scan) ...[
          const SizedBox(height: 12),
          AppTextField(label: 'Body part', icon: Icons.accessibility_new_rounded, controller: _body),
        ],
        const SizedBox(height: 16),
        Text(scan ? 'SCAN TYPE' : 'DOCUMENT TYPE', style: AppTheme.label()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(labels.length, (i) {
            final sel = i == _kind;
            return GestureDetector(
              onTap: () => setState(() => _kind = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? accent : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? accent : Colors.white),
                ),
                child: Text(labels[i],
                    style: AppTheme.body(13,
                        color: sel ? Colors.white : AppColors.text, weight: FontWeight.w600)),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        // photo area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withOpacity(0.35), width: 1.2),
          ),
          child: _attached
              ? Row(children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text('Photo attached (prototype)',
                          style: AppTheme.body(14, weight: FontWeight.w600))),
                  TextButton(
                      onPressed: () => setState(() => _attached = false),
                      child: const Text('Change')),
                ])
              : Column(children: [
                  Icon(Icons.add_a_photo_rounded, color: accent, size: 30),
                  const SizedBox(height: 6),
                  Text(scan ? 'Add a photo of the scan film' : 'Add a photo of the document',
                      style: AppTheme.body(13.5, color: AppColors.tan)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _photoBtn(Icons.photo_camera_rounded, 'Camera', accent)),
                    const SizedBox(width: 10),
                    Expanded(child: _photoBtn(Icons.photo_library_rounded, 'Gallery', accent)),
                  ]),
                ]),
        ),
        const SizedBox(height: 20),
        PillButton(
          label: scan ? 'SAVE SCAN' : 'SAVE DOCUMENT',
          color: scan ? AppColors.scanDark : null,
          onPressed: () => widget.onSave(_title.text.trim(), _kind, _body.text.trim()),
        ),
      ],
    );
  }

  Widget _photoBtn(IconData icon, String label, Color accent) => OutlinedButton.icon(
        onPressed: () => setState(() => _attached = true),
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
}
