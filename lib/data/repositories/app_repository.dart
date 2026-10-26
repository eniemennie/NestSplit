import '../models/activity_item.dart';
import '../models/chore.dart';
import '../models/expense.dart';
import '../models/house_rule.dart';
import '../models/landlord_models.dart';
import '../models/member.dart';
import '../models/swap_request.dart';

/// Everything the tenant side needs on first load.
class HouseholdSnapshot {
  const HouseholdSnapshot({
    required this.householdName,
    required this.inviteCode,
    required this.currentUserId,
    required this.members,
    required this.chores,
    required this.swaps,
    required this.activity,
    required this.rules,
    required this.expenses,
    required this.doneThisWeek,
    required this.streakWeeks,
    required this.totalChoresThisWeek,
  });

  final String householdName;
  final String inviteCode;
  final String currentUserId;
  final List<Member> members;
  final List<Chore> chores;
  final List<SwapRequest> swaps;
  final List<ActivityItem> activity;
  final List<HouseRule> rules;
  final List<Expense> expenses;

  /// memberId -> chores completed this week.
  final Map<String, int> doneThisWeek;

  /// memberId -> consecutive weeks with all chores done.
  final Map<String, int> streakWeeks;
  final int totalChoresThisWeek;
}

/// Everything the landlord side needs on first load.
class PropertySnapshot {
  const PropertySnapshot({
    required this.id,
    required this.propertyName,
    required this.inviteCode,
    required this.rooms,
    required this.rent,
    required this.repairs,
    required this.notices,
    required this.templates,
    required this.acceptances,
    required this.recentActivity,
  });

  final String id;
  final String propertyName;
  final String inviteCode;
  final List<Room> rooms;
  final List<RentRecord> rent;
  final List<RepairRequest> repairs;
  final List<Notice> notices;
  final List<RuleTemplate> templates;
  final List<Acceptance> acceptances;
  final List<String> recentActivity;
}

/// The single place the UI talks to for data.
///
/// TODO(backend): to connect Firebase (or any API), create a class that
/// implements this interface (for example FirebaseAppRepository) and pass it to
/// AppServices in main.dart. No screen code needs to change.
/// The save* methods are called after the UI state has already changed.
abstract class AppRepository {
  Future<HouseholdSnapshot> loadHousehold();
  /// All boarding houses the landlord manages.
  Future<List<PropertySnapshot>> loadProperties();

  Future<void> saveChore(Chore chore);
  Future<void> saveSwap(SwapRequest swap);
  Future<void> saveRule(HouseRule rule);
  Future<void> saveExpense(Expense expense);
  Future<void> saveRent(RentRecord record);
  Future<void> saveRepair(RepairRequest repair);
  Future<void> saveNotice(Notice notice);
}
