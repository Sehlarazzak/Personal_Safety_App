import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/trusted_contact_model.dart';
import '../../data/repositories/contacts_repository.dart';

/// Drives the Add/Edit Contact form.
///
/// Mirrors `add_edit_contact/code.html`: name, phone, relationship
/// picker, and a "Primary Emergency Contact" toggle. When [existingContact]
/// is non-null, the form is pre-filled and a Delete action is available.
class AddEditContactViewModel extends ChangeNotifier {
  final ContactsRepository _repository;
  final String userId;
  final TrustedContactModel? existingContact;
  static const _uuid = Uuid();

  AddEditContactViewModel({
    required ContactsRepository repository,
    required this.userId,
    this.existingContact,
  }) : _repository = repository {
    if (existingContact != null) {
      nameController.text = existingContact!.name;
      phoneController.text = existingContact!.phoneNumber;
      relationship = existingContact!.relationship;
      isPrimary = existingContact!.isPrimary;
    }
  }

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  ContactRelationship relationship = ContactRelationship.family;
  bool isPrimary = false;
  bool isSubmitting = false;
  String? errorMessage;

  bool get isEditing => existingContact != null;

  void setRelationship(ContactRelationship value) {
    relationship = value;
    notifyListeners();
  }

  void setIsPrimary(bool value) {
    isPrimary = value;
    notifyListeners();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().length < 2) return 'Enter a valid name';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 7) return 'Enter a valid phone number';
    return null;
  }

  /// Returns true on success so the View can pop back to the list.
  Future<bool> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final contact = TrustedContactModel(
        id: existingContact?.id ?? _uuid.v4(),
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        relationship: relationship,
        isPrimary: isPrimary,
      );

      if (isEditing) {
        await _repository.updateContact(userId, contact);
      } else {
        await _repository.addContact(userId, contact);
      }

      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Could not save this contact. Please try again.';
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete() async {
    final contact = existingContact;
    if (contact == null) return false;

    isSubmitting = true;
    notifyListeners();

    try {
      await _repository.deleteContact(userId, contact.id);
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Could not delete this contact. Please try again.';
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
