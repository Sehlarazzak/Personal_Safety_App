/// Lightweight user model used throughout the app shell and dashboard.
///
/// Module 1 kept this free of any backend dependency. Module 2 adds
/// [UserModel.fromFirebaseUser] and [UserModel.fromMap] so the same model
/// can be built from `firebase_auth`'s `User` right after sign-in, or from
/// a richer Firestore `users/{uid}` profile document once one exists —
/// without any View code needing to change.
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.photoUrl,
  });

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  factory UserModel.guest() => const UserModel(
        id: 'guest',
        fullName: 'Guest User',
        email: '',
      );

  /// Builds a [UserModel] straight from `firebase_auth`'s `User` object.
  /// Used immediately after sign-in/registration, before a fuller profile
  /// document (if any) has loaded from Firestore.
  factory UserModel.fromFirebaseUser({
    required String uid,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    return UserModel(
      id: uid,
      fullName: (displayName == null || displayName.trim().isEmpty)
          ? (email?.split('@').first ?? 'User')
          : displayName,
      email: email ?? '',
      photoUrl: photoUrl,
    );
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      fullName: map['fullName'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}
