import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/trusted_contact_model.dart';
import '../../data/repositories/contacts_repository.dart';

/// Drives the Emergency Contacts list screen: a live stream of the
/// signed-in user's trusted contacts, sorted primary-first (the
/// repository already orders this way).
class ContactsViewModel extends ChangeNotifier {
  final ContactsRepository _repository;
  final String userId;

  StreamSubscription<List<TrustedContactModel>>? _subscription;

  List<TrustedContactModel> contacts = [];
  bool isLoading = true;
  String? errorMessage;

  ContactsViewModel({
    required ContactsRepository repository,
    required this.userId,
  }) : _repository = repository {
    _subscription = _repository.watchContacts(userId).listen(
      (list) {
        contacts = list;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'Could not load your contacts. Pull down to try again.';
        notifyListeners();
      },
    );
  }

  Future<void> deleteContact(String contactId) async {
    await _repository.deleteContact(userId, contactId);
  }

  Future<void> setPrimary(String contactId) async {
    await _repository.setPrimaryContact(userId, contactId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
