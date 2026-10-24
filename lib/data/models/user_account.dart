/// Which side of the app an account uses.
enum AccountRole { tenant, landlord }

/// The signed-in person. Passwords are never stored here.
class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.memberId,
  });

  final String id;
  final String name;
  final String email;
  final AccountRole role;

  /// For tenants: the household member this account is.
  final String? memberId;

  UserAccount copyWith({String? name}) {
    return UserAccount(id: id, name: name ?? this.name, email: email, role: role, memberId: memberId);
  }
}
