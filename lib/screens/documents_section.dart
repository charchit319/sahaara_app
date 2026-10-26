import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../data/files_store.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_text_field.dart';
import '../widgets/card_actions.dart';
import '../widgets/empty_state.dart';
import '../widgets/pill_button.dart';

/// Documents (paper: cream/maroon) and X-rays & scans (dark "lightbox", cool blue)
/// share one section but look completely different and have separate add-forms.
class DocumentsSection extends StatefulWidget {
  final String personId;
  final bool readOnly; // true = can look, cannot add or delete
  const DocumentsSection({super.key, required this.personId, required this.readOnly});

  @override
  State<DocumentsSection> createState() => _DocumentsSectionState();
}

class _DocumentsSectionState extends State<DocumentsSection> {
  bool _scans = false;

  @override
  void initState() {
    super.initState();
    filesStore.addListener(_refresh);
  }

  @override
  void dispose() {
    filesStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

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
            Expanded(
                child: _tile(
                    scan: false,
                    label: 'Documents',
                    icon: Icons.description_rounded,
                    count: _docs.length)),
            const SizedBox(width: 12),
            Expanded(
                child: _tile(
                    scan: true,
                    label: 'X-rays & Scans',
                    icon: Icons.biotech_rounded,
                    count: _scanItems.length)),
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
        Expanded(child: _content()),
      ],
    );
  }

  Widget _content() {
    final nothingYet = mockDocuments.isEmpty && mockScans.isEmpty;
    if (filesStore.loading && nothingYet) {
      return const Center(child: CircularProgressIndicator(color: AppColors.maroon));
    }
    if (filesStore.error != null && nothingYet) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Something went wrong',
        message: filesStore.error!,
        actionLabel: 'TRY AGAIN',
        actionIcon: Icons.refresh_rounded,
        onAction: filesStore.load,
        dark: _scans,
      );
    }
    return _scans ? _scanGrid() : _docGrid();
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
  Widget _empty(String title) => EmptyState(
        icon: _scans ? Icons.biotech_rounded : Icons.description_rounded,
        title: title,
        message: widget.readOnly
            ? 'Nothing has been added here yet.'
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
    if (items.isEmpty) return _empty('No documents yet');
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
      gridDelegate: _delegate,
      itemCount: items.length,
      itemBuilder: (_, i) {
        final d = items[i];
        return _DocCard(item: d, url: filesStore.urlFor(d.filePath), onTap: () => _openDoc(d));
      },
    );
  }

  Widget _scanGrid() {
    final items = _scanItems;
    if (items.isEmpty) return _empty('No X-rays or scans yet');
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
      gridDelegate: _delegate,
      itemCount: items.length,
      itemBuilder: (_, i) {
        final s = items[i];
        return _ScanCard(item: s, url: filesStore.urlFor(s.filePath), onTap: () => _openScan(s));
      },
    );
  }

  // ───────── viewer ─────────
  Future<bool> _confirmAndDelete(String what, Future<void> Function() action) async {
    if (!await confirmDelete(context, what)) return false;
    try {
      await action();
      return true;
    } catch (e) {
      debugPrint('Delete failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not delete. Please try again.',
                style: AppTheme.body(14, color: AppColors.sand))));
      }
      return false;
    }
  }

  void _openDoc(DocumentItem d) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _ViewerPage(
        title: d.title,
        url: filesStore.urlFor(d.filePath),
        dark: false,
        fallbackIcon: d.kind.icon,
        details: [('Type', d.kind.label), ('Added', DateFormat('MMM d, y').format(d.date))],
        onDelete: widget.readOnly
            ? null
            : () => _confirmAndDelete('this document', () => filesStore.deleteDocument(d)),
      ),
    ));
  }

  void _openScan(ScanItem s) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _ViewerPage(
        title: s.title,
        url: filesStore.urlFor(s.filePath),
        dark: true,
        fallbackIcon: s.kind.icon,
        details: [
          ('Scan type', s.kind.label),
          ('Body part', s.bodyPart),
          ('Facility', s.facility),
          ('Date', DateFormat('MMM d, y').format(s.date)),
        ],
        onDelete: widget.readOnly
            ? null
            : () => _confirmAndDelete('this scan', () => filesStore.deleteScan(s)),
      ),
    ));
  }

  // ───────── add ─────────
  void _openAdd() {
    final scan = _scans;
    showAppSheet<void>(
      context,
      title: scan ? 'Add X-ray / scan' : 'Add document',
      child: _AddItemForm(
        scan: scan,
        onSave: (title, kindIndex, bodyPart, facility, bytes, ext, mime) async {
          if (scan) {
            final k = ScanKind.values[kindIndex];
            await filesStore.addScan(
              personId: widget.personId,
              title: title.isEmpty ? k.label : title,
              kind: k,
              bodyPart: bodyPart,
              facility: facility,
              bytes: bytes,
              ext: ext,
              mime: mime,
            );
          } else {
            final k = DocKind.values[kindIndex];
            await filesStore.addDocument(
              personId: widget.personId,
              title: title.isEmpty ? k.label : title,
              kind: k,
              bytes: bytes,
              ext: ext,
              mime: mime,
            );
          }
        },
      ),
    );
  }
}

// ───────────────────────── full-screen viewer ─────────────────────────

class _ViewerPage extends StatelessWidget {
  final String title;
  final String? url;
  final bool dark;
  final IconData fallbackIcon;
  final List<(String, String)> details;
  final Future<bool> Function()? onDelete;

  const _ViewerPage({
    required this.title,
    required this.url,
    required this.dark,
    required this.fallbackIcon,
    required this.details,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.maroon;
    final sub = dark ? AppColors.scanAccent : AppColors.tan;

    return Scaffold(
      backgroundColor: dark ? Colors.black : AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: fg,
        title: Text(title, style: AppTheme.heading(18, color: fg)),
      ),
      body: Column(
        children: [
          Expanded(
            child: url == null
                ? Center(child: Icon(fallbackIcon, size: 80, color: sub))
                : InteractiveViewer(
                    minScale: 1,
                    maxScale: 6,
                    child: Center(
                      child: Image.network(
                        url!,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, p) => p == null
                            ? child
                            : Center(child: CircularProgressIndicator(color: fg)),
                        errorBuilder: (_, __, ___) => Center(
                          child: Text('Could not load the photo.\nGo back and reopen it.',
                              textAlign: TextAlign.center,
                              style: AppTheme.body(14, color: sub)),
                        ),
                      ),
                    ),
                  ),
          ),
          Container(
            width: double.infinity,
            color: dark ? const Color(0xFF0E1218) : Colors.white.withOpacity(0.6),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (k, v) in details)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        SizedBox(
                            width: 100,
                            child: Text(k.toUpperCase(),
                                style: AppTheme.label().copyWith(color: sub))),
                        Expanded(
                            child: Text(v,
                                style: AppTheme.body(14.5,
                                    color: dark ? Colors.white : AppColors.text,
                                    weight: FontWeight.w600))),
                      ]),
                    ),
                  if (onDelete != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final ok = await onDelete!();
                          if (ok && context.mounted) Navigator.pop(context);
                        },
                        icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                        label: Text('Delete',
                            style: AppTheme.body(14,
                                color: Colors.red.shade400, weight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── cards ─────────────────────────

class _PaperLines extends StatelessWidget {
  const _PaperLines();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }
}

class _DocCard extends StatelessWidget {
  final DocumentItem item;
  final String? url;
  final VoidCallback onTap;
  const _DocCard({required this.item, required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: AppColors.maroon.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.cream.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (url != null)
                      Image.network(
                        url!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _PaperLines(),
                        loadingBuilder: (_, child, p) => p == null
                            ? child
                            : const Center(
                                child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: AppColors.maroon))),
                      )
                    else
                      const _PaperLines(),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: AppColors.maroon, shape: BoxShape.circle),
                        child: Icon(item.kind.icon, size: 14, color: AppColors.sand),
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
  final String? url;
  final VoidCallback onTap;
  const _ScanCard({required this.item, required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.scanDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.scanAccent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const RadialGradient(
                      colors: [Color(0xFF2B3644), Color(0xFF0E1218)], radius: 0.9),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (url != null)
                      Image.network(
                        url!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                            child: Icon(item.kind.icon,
                                size: 46, color: AppColors.scanAccent.withOpacity(0.8))),
                        loadingBuilder: (_, child, p) => p == null
                            ? child
                            : const Center(
                                child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: AppColors.scanAccent))),
                      )
                    else
                      Center(
                          child: Icon(item.kind.icon,
                              size: 46, color: AppColors.scanAccent.withOpacity(0.8))),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.scanDark.withOpacity(0.7),
                          border: Border.all(color: AppColors.scanAccent.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item.kind.label.toUpperCase(),
                            style: AppTheme.body(9.5,
                                    color: AppColors.scanAccent, weight: FontWeight.w800)
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
  final Future<void> Function(String title, int kindIndex, String bodyPart, String facility,
      Uint8List bytes, String ext, String? mime) onSave;
  const _AddItemForm({required this.scan, required this.onSave});

  @override
  State<_AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<_AddItemForm> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _facility = TextEditingController();
  int _kind = 0;
  Uint8List? _bytes;
  String _ext = 'jpg';
  String? _mime;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _facility.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final f = await ImagePicker().pickImage(source: source, maxWidth: 2400, imageQuality: 85);
      if (f == null) return;
      final bytes = await f.readAsBytes();
      final dot = f.name.lastIndexOf('.');
      var ext = dot >= 0 ? f.name.substring(dot + 1).toLowerCase() : 'jpg';
      if (!['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext)) ext = 'jpg';
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _ext = ext;
        _mime = f.mimeType ??
            (ext == 'png'
                ? 'image/png'
                : ext == 'webp'
                    ? 'image/webp'
                    : ext == 'heic'
                        ? 'image/heic'
                        : 'image/jpeg');
        _error = null;
      });
    } catch (e) {
      debugPrint('Picking image failed: $e');
      if (mounted) setState(() => _error = 'Could not open the camera or gallery.');
    }
  }

  Future<void> _save() async {
    if (_bytes == null) {
      setState(() => _error = 'Please add a photo first.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(_title.text.trim(), _kind, _body.text.trim(), _facility.text.trim(),
          _bytes!, _ext, _mime);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Saving file failed: $e');
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not upload. Check your connection and try again.';
        });
      }
    }
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
          AppTextField(
              label: 'Body part', icon: Icons.accessibility_new_rounded, controller: _body),
          const SizedBox(height: 12),
          AppTextField(
              label: 'Hospital / facility (optional)',
              icon: Icons.local_hospital_outlined,
              controller: _facility),
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
          child: Column(children: [
            if (_bytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(_bytes!,
                    height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Icon(Icons.add_a_photo_rounded, color: accent, size: 30),
              const SizedBox(height: 6),
              Text(scan ? 'Add a photo of the scan film' : 'Add a photo of the document',
                  style: AppTheme.body(13.5, color: AppColors.tan)),
              const SizedBox(height: 12),
            ],
            Row(children: [
              Expanded(
                  child: _photoBtn(Icons.photo_camera_rounded,
                      _bytes == null ? 'Camera' : 'Retake', ImageSource.camera, accent)),
              const SizedBox(width: 10),
              Expanded(
                  child: _photoBtn(Icons.photo_library_rounded,
                      _bytes == null ? 'Gallery' : 'Change', ImageSource.gallery, accent)),
            ]),
          ]),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: AppTheme.body(13, color: Colors.red.shade700)),
        ],
        const SizedBox(height: 20),
        PillButton(
          label: _saving ? 'UPLOADING…' : (scan ? 'SAVE SCAN' : 'SAVE DOCUMENT'),
          color: scan ? AppColors.scanDark : null,
          onPressed: _saving ? () {} : _save,
        ),
      ],
    );
  }

  Widget _photoBtn(IconData icon, String label, ImageSource source, Color accent) =>
      OutlinedButton.icon(
        onPressed: _saving ? null : () => _pick(source),
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