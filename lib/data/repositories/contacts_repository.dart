import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trusted_contact_model.dart';

/// Abstraction over trusted-contact persistence, scoped per signed-in
/// user. Keeps `ContactsViewModel` (and anything else that needs
/// contacts, like the dashboard or the emergency-dispatch flow in
/// Module 4) ignorant of Firestore's API.
abstract class ContactsRepository {
  /// Live list of the user's trusted contacts, primary contact first.
  Stream<List<TrustedContactModel>> watchContacts(String userId);

  Future<TrustedContactModel?> getContact(String userId, String contactId);

  Future<void> addContact(String userId, TrustedContactModel contact);

  Future<void> updateContact(String userId, TrustedContactModel contact);

  Future<void> deleteContact(String userId, String contactId);

  /// Ensures at most one contact is marked primary — demoting the
  /// previous primary contact (if any) when a new one is set.
  Future<void> setPrimaryContact(String userId, String contactId);
}

/// Cloud Firestore implementation of [ContactsRepository].
///
/// Data model: `users/{userId}/contacts/{contactId}`. Nesting contacts
/// under the owning user keeps security rules simple (a user can only
/// ever read/write their own subcollection).
class FirestoreContactsRepository implements ContactsRepository {
  final FirebaseFirestore _firestore;

  FirestoreContactsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _contactsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('contacts');

  @override
  Stream<List<TrustedContactModel>> watchContacts(String userId) {
    return _contactsRef(userId).orderBy('isPrimary', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => TrustedContactModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<TrustedContactModel?> getContact(String userId, String contactId) async {
    final doc = await _contactsRef(userId).doc(contactId).get();
    if (!doc.exists) return null;
    return TrustedContactModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> addContact(String userId, TrustedContactModel contact) async {
    if (contact.isPrimary) {
      await _demoteExistingPrimary(userId);
    }
    await _contactsRef(userId).doc(contact.id).set(contact.toMap());
  }

  @override
  Future<void> updateContact(String userId, TrustedContactModel contact) async {
    if (contact.isPrimary) {
      await _demoteExistingPrimary(userId, exceptId: contact.id);
    }
    await _contactsRef(userId).doc(contact.id).update(contact.toMap());
  }

  @override
  Future<void> deleteContact(String userId, String contactId) async {
    await _contactsRef(userId).doc(contactId).delete();
  }

  @override
  Future<void> setPrimaryContact(String userId, String contactId) async {
    await _demoteExistingPrimary(userId, exceptId: contactId);
    await _contactsRef(userId).doc(contactId).update({'isPrimary': true});
  }

  Future<void> _demoteExistingPrimary(String userId, {String? exceptId}) async {
    final existingPrimary = await _contactsRef(userId).where('isPrimary', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (final doc in existingPrimary.docs) {
      if (doc.id == exceptId) continue;
      batch.update(doc.reference, {'isPrimary': false});
    }
    await batch.commit();
  }
}
