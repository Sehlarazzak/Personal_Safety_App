/// How a trusted contact relates to the user — drives the icon/label shown
/// on the Add/Edit Contact screen's relationship picker.
enum ContactRelationship { family, friend, colleague, other }

extension ContactRelationshipX on ContactRelationship {
  String get label {
    switch (this) {
      case ContactRelationship.family:
        return 'Family';
      case ContactRelationship.friend:
        return 'Friend';
      case ContactRelationship.colleague:
        return 'Colleague';
      case ContactRelationship.other:
        return 'Other';
    }
  }

  static ContactRelationship fromName(String? name) {
    return ContactRelationship.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ContactRelationship.other,
    );
  }
}

/// Trusted (emergency) contact model.
///
/// Module 1 only needed enough shape to render a mock summary card.
/// Module 2 adds the fields the real Add/Edit Contact screen and
/// Firestore persistence need: [relationship], [toMap]/[fromMap], and
/// [copyWith] for in-place edits.
class TrustedContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final ContactRelationship relationship;
  final bool isPrimary;

  const TrustedContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship = ContactRelationship.other,
    this.isPrimary = false,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  TrustedContactModel copyWith({
    String? name,
    String? phoneNumber,
    ContactRelationship? relationship,
    bool? isPrimary,
  }) {
    return TrustedContactModel(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  factory TrustedContactModel.fromMap(String id, Map<String, dynamic> map) {
    return TrustedContactModel(
      id: id,
      name: map['name'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      relationship: ContactRelationshipX.fromName(map['relationship'] as String?),
      isPrimary: map['isPrimary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship.name,
      'isPrimary': isPrimary,
    };
  }
}
