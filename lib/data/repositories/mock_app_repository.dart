import '../models/activity_item.dart';
import '../models/chore.dart';
import '../models/expense.dart';
import '../models/house_rule.dart';
import '../models/landlord_models.dart';
import '../models/member.dart';
import '../models/swap_request.dart';
import 'app_repository.dart';
import 'sample_properties.dart';

/// TEMPORARY DATA. Everything below is sample data matching the mockup so the app
/// can run without a backend. Replace by implementing [AppRepository] with a real
/// data source. Nothing here is saved between app launches.
class MockAppRepository implements AppRepository {
  static const Member ana = Member(id: 'ana', name: 'Ana', color: MemberColor.blue);
  static const Member ben = Member(id: 'ben', name: 'Ben', color: MemberColor.pink);
  static const Member carlo = Member(id: 'carlo', name: 'Carlo', color: MemberColor.lime);
  static const Member dani = Member(id: 'dani', name: 'Dani', color: MemberColor.navy);

  @override
  Future<HouseholdSnapshot> loadHousehold() async {
    return HouseholdSnapshot(
      householdName: 'Casa Lakbay',
      inviteCode: 'LKB-482',
      currentUserId: 'ben',
      members: const [ana, ben, carlo, dani],
      chores: const [
        Chore(id: 'c1', name: 'Dishes', assigneeId: 'ana', day: 'Mon', dueFull: 'Monday', status: ChoreStatus.done, iconKey: 'dishes'),
        Chore(id: 'c2', name: 'Trash', assigneeId: 'ben', day: 'Tue', dueFull: 'Tuesday', status: ChoreStatus.overdue, iconKey: 'trash'),
        Chore(id: 'c3', name: 'Sweep floor', assigneeId: 'carlo', day: 'Wed', dueFull: 'Wednesday', status: ChoreStatus.todo, iconKey: 'sweep'),
        Chore(id: 'c4', name: 'Clean bathroom', assigneeId: 'ana', day: 'Thu', dueFull: 'Thursday', status: ChoreStatus.done, iconKey: 'bathroom', difficulty: Difficulty.heavy),
        Chore(id: 'c5', name: 'Wipe kitchen counter', assigneeId: 'dani', day: 'Fri', dueFull: 'Friday', status: ChoreStatus.todo, iconKey: 'sparkle', difficulty: Difficulty.light),
        Chore(id: 'c6', name: 'Mop', assigneeId: 'ana', day: 'Sat', dueFull: 'Saturday', status: ChoreStatus.done, iconKey: 'mop'),
        Chore(id: 'c7', name: 'Wipe kitchen counter', assigneeId: 'ben', day: 'Today', dueFull: 'Today', status: ChoreStatus.todo, iconKey: 'sparkle', difficulty: Difficulty.light),
        Chore(id: 'c8', name: 'Take out recycling', assigneeId: 'carlo', day: 'Sun', dueFull: 'Sunday', status: ChoreStatus.todo, iconKey: 'recycle', difficulty: Difficulty.light),
        Chore(id: 'c9', name: 'Clean fridge', assigneeId: 'ana', day: 'Mon', dueFull: 'Monday', status: ChoreStatus.done, iconKey: 'sparkle'),
        Chore(id: 'c10', name: 'Water plants', assigneeId: 'ben', day: 'Tue', dueFull: 'Tuesday', status: ChoreStatus.done, iconKey: 'water', difficulty: Difficulty.light),
        Chore(id: 'c11', name: 'Organize shoes', assigneeId: 'ben', day: 'Wed', dueFull: 'Wednesday', status: ChoreStatus.done, iconKey: 'sparkle', difficulty: Difficulty.light),
        Chore(id: 'c12', name: 'Dust shelves', assigneeId: 'carlo', day: 'Thu', dueFull: 'Thursday', status: ChoreStatus.done, iconKey: 'sweep', difficulty: Difficulty.light),
        Chore(id: 'c13', name: 'Refill water jug', assigneeId: 'dani', day: 'Fri', dueFull: 'Friday', status: ChoreStatus.done, iconKey: 'water', difficulty: Difficulty.light),
        Chore(id: 'c14', name: 'Wash windows', assigneeId: 'ana', day: 'Sat', dueFull: 'Saturday', status: ChoreStatus.done, iconKey: 'sparkle', difficulty: Difficulty.heavy),
      ],
      swaps: const [
        SwapRequest(id: 's1', requesterId: 'carlo', targetId: 'ben', offeredChore: 'Sweep floor', requestedChore: 'Wipe kitchen counter', reason: 'Exam on Wed'),
        SwapRequest(id: 's2', requesterId: 'dani', targetId: 'ben', offeredChore: 'Mop', requestedChore: 'Trash', reason: 'Away this weekend'),
        SwapRequest(id: 's3', requesterId: 'ben', targetId: 'ana', offeredChore: 'Trash', reason: ''),
      ],
      activity: const [
        ActivityItem(id: 'a1', memberId: 'ana', message: 'finished Mop', timeLabel: '10:12', isToday: true),
        ActivityItem(id: 'a2', memberId: 'carlo', message: 'asked to swap Sweep floor', timeLabel: '09:40', isToday: true),
        ActivityItem(id: 'a3', memberId: 'ben', message: 'Trash is now a day behind', timeLabel: '08:00', isToday: true),
        ActivityItem(id: 'a4', memberId: 'ana', message: 'finished Clean bathroom', timeLabel: 'Thu', isToday: false),
        ActivityItem(id: 'a5', memberId: 'dani', message: 'joined Casa Lakbay', timeLabel: 'Wed', isToday: false),
        ActivityItem(id: 'a6', memberId: 'ana', message: 'finished Dishes', timeLabel: 'Mon', isToday: false),
      ],
      rules: const [
        HouseRule(id: 'r1', text: 'Dishes washed the same day'),
        HouseRule(id: 'r2', text: 'Trash out before 8 PM on Tue & Fri'),
        HouseRule(id: 'r3', text: 'Quiet hours after 11 PM'),
        HouseRule(id: 'r4', text: 'Ask before swapping a chore'),
      ],
      expenses: const <Expense>[],
      doneThisWeek: const {'ana': 6, 'ben': 3, 'carlo': 2, 'dani': 1},
      streakWeeks: const {'ana': 4, 'ben': 2, 'carlo': 0, 'dani': 0},
      totalChoresThisWeek: 14,
    );
  }

  @override
  Future<List<PropertySnapshot>> loadProperties() async {
    return SampleProperties.all(ana: ana, ben: ben, carlo: carlo, dani: dani);
  }

  // The mock repository keeps nothing; the in-memory state classes hold the data.
  @override
  Future<void> saveChore(Chore chore) async {}
  @override
  Future<void> saveSwap(SwapRequest swap) async {}
  @override
  Future<void> saveRule(HouseRule rule) async {}
  @override
  Future<void> saveExpense(Expense expense) async {}
  @override
  Future<void> saveRent(RentRecord record) async {}
  @override
  Future<void> saveRepair(RepairRequest repair) async {}
  @override
  Future<void> saveNotice(Notice notice) async {}
}
