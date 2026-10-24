/// Which brand color a member's avatar uses.
enum MemberColor { blue, pink, lime, navy }

/// A person living in the household (or a tenant seen by the landlord).
class Member {
  const Member({required this.id, required this.name, required this.color});

  final String id;
  final String name;
  final MemberColor color;

  String get initial => name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
}
