import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import 'mock_data.dart';

const _bucket = 'health-files';

/// Documents and X-rays/scans: rows in the database, photos in private storage.
class FilesStore extends ChangeNotifier {
  bool loading = false;
  String? error;

  /// file path -> temporary signed link (the bucket is private)
  final Map<String, String> _urls = {};
  String? urlFor(String? path) => path == null ? null : _urls[path];

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final docs = await supabase.from('documents').select().order('added_on', ascending: false);
      final scans = await supabase.from('scans').select().order('scanned_on', ascending: false);
      mockDocuments
        ..clear()
        ..addAll(docs.map(DocumentItem.fromRow));
      mockScans
        ..clear()
        ..addAll(scans.map(ScanItem.fromRow));
      _urls.clear();
      await _sign([
        ...mockDocuments.map((d) => d.filePath),
        ...mockScans.map((s) => s.filePath),
      ]);
    } catch (e) {
      debugPrint('Loading files failed: $e');
      error = 'Could not load documents. Check your connection and try again.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> _sign(Iterable<String?> paths) async {
    final list = paths.whereType<String>().where((p) => !_urls.containsKey(p)).toList();
    if (list.isEmpty) return;
    final signed = await supabase.storage.from(_bucket).createSignedUrls(list, 3600);
    for (final s in signed) {
      if (s.signedUrl.isNotEmpty) _urls[s.path] = s.signedUrl;
    }
  }

  Future<String> _upload(
      String personId, String prefix, Uint8List bytes, String ext, String? mime) async {
    // stored as  <person_id>/<prefix>_<timestamp>.<ext>   (the security rules read the first folder)
    final path = '$personId/${prefix}_${DateTime.now().microsecondsSinceEpoch}.$ext';
    await supabase.storage
        .from(_bucket)
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: mime ?? 'image/jpeg'));
    return path;
  }

  Future<void> addDocument({
    required String personId,
    required String title,
    required DocKind kind,
    required Uint8List bytes,
    required String ext,
    String? mime,
  }) async {
    final path = await _upload(personId, 'doc', bytes, ext, mime);
    try {
      final row = await supabase
          .from('documents')
          .insert({'person_id': personId, 'title': title, 'kind': kind.db, 'file_path': path})
          .select()
          .single();
      mockDocuments.insert(0, DocumentItem.fromRow(row));
      await _sign([path]);
    } catch (e) {
      await supabase.storage.from(_bucket).remove([path]); // don't leave an orphan photo
      rethrow;
    }
    notifyListeners();
  }

  Future<void> addScan({
    required String personId,
    required String title,
    required ScanKind kind,
    required String bodyPart,
    required String facility,
    required Uint8List bytes,
    required String ext,
    String? mime,
  }) async {
    final path = await _upload(personId, 'scan', bytes, ext, mime);
    try {
      final row = await supabase
          .from('scans')
          .insert({
            'person_id': personId,
            'title': title,
            'modality': kind.db,
            'body_part': bodyPart.isEmpty ? null : bodyPart,
            'facility': facility.isEmpty ? null : facility,
            'file_path': path,
          })
          .select()
          .single();
      mockScans.insert(0, ScanItem.fromRow(row));
      await _sign([path]);
    } catch (e) {
      await supabase.storage.from(_bucket).remove([path]);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> deleteDocument(DocumentItem d) async {
    await supabase.from('documents').delete().eq('id', d.id);
    await _removeFile(d.filePath);
    mockDocuments.removeWhere((x) => x.id == d.id);
    notifyListeners();
  }

  Future<void> deleteScan(ScanItem s) async {
    await supabase.from('scans').delete().eq('id', s.id);
    await _removeFile(s.filePath);
    mockScans.removeWhere((x) => x.id == s.id);
    notifyListeners();
  }

  Future<void> _removeFile(String? path) async {
    if (path == null) return;
    _urls.remove(path);
    try {
      await supabase.storage.from(_bucket).remove([path]);
    } catch (e) {
      debugPrint('Removing file failed: $e');
    }
  }

  void clear() {
    _urls.clear();
    error = null;
    loading = false;
    notifyListeners();
  }
}

final filesStore = FilesStore();