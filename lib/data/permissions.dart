import '../config.dart';
import 'mock_data.dart';

String? get myId => supabase.auth.currentUser?.id;

/// True if I created this record (the only one who manages its access).
bool isOwnerOf(Person p) => p.ownerId != null && p.ownerId == myId;

/// My access row for this person, if any.
AccessMember? myAccessTo(String personId) {
  for (final m in mockAccess[personId] ?? const <AccessMember>[]) {
    if (m.userId == myId) return m;
  }
  return null;
}

/// Can add / edit / delete visits, records, documents and scans.
bool canEditPerson(Person p) => isOwnerOf(p) || myAccessTo(p.id)?.level == AccessLevel.full;

/// Can see medical history, documents and scans (everything except "Limited").
bool canSeeAll(Person p) =>
    isOwnerOf(p) || (myAccessTo(p.id)?.level ?? AccessLevel.limited) != AccessLevel.limited;