/// Lightweight user model used by the app shell and dashboard header.
///
/// Module 1 keeps this deliberately free of any backend/auth dependency
/// so the UI can be built and navigated end-to-end before Firebase
/// Authentication is wired up in Module 2.
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
}
