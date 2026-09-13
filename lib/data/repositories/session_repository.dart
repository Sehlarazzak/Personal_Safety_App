import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/safety_session_model.dart';

/// Abstraction over persisting Safety Timer & Check-In sessions.
///
/// Module 3 only needs [createSession] and [updateSession] to log a
/// session's lifecycle as it happens. Module 5 (Safety History) reuses
/// this same repository's [watchRecentSessions] to render the log — no
/// duplicate data-access code needed.
abstract class SessionRepository {
  Future<void> createSession(String userId, SafetySessionModel session);

  Future<void> updateSession(String userId, SafetySessionModel session);

  Stream<List<SafetySessionModel>> watchRecentSessions(String userId, {int limit = 50});
}

/// Firestore implementation of [SessionRepository].
///
/// Data model: `users/{userId}/sessions/{sessionId}`.
class FirestoreSessionRepository implements SessionRepository {
  final FirebaseFirestore _firestore;

  FirestoreSessionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sessionsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('sessions');

  @override
  Future<void> createSession(String userId, SafetySessionModel session) async {
    await _sessionsRef(userId).doc(session.id).set(session.toMap());
  }

  @override
  Future<void> updateSession(String userId, SafetySessionModel session) async {
    await _sessionsRef(userId).doc(session.id).update(session.toMap());
  }

  @override
  Stream<List<SafetySessionModel>> watchRecentSessions(String userId, {int limit = 50}) {
    return _sessionsRef(userId)
        .orderBy('startTimeMs', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SafetySessionModel.fromMap(doc.id, doc.data())).toList());
  }
}
