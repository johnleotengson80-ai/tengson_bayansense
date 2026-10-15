import '../constants/app_strings.dart';

enum UserRole { resident, staff, admin }

class UserAccount {
  const UserAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.department,
  });

  final int id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? department;

  String get roleLabel {
    switch (role) {
      case UserRole.resident:
        return AppStrings.residentRole;
      case UserRole.staff:
        return AppStrings.staffRole;
      case UserRole.admin:
        return AppStrings.adminRole;
    }
  }
}
