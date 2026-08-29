/// Trusted (emergency) contact model.
///
/// Module 1 only needs enough shape to render the "Trusted Contacts"
/// summary card on the dashboard with mock data. Persistence and full
/// CRUD screens are built in Module 2.
class TrustedContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final bool isPrimary;

  const TrustedContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.isPrimary = false,
  });
}
