import 'package:flutter/foundation.dart';

import '../core/utils/split_calculator.dart';
import '../data/models/activity_item.dart';
import '../data/models/chore.dart';
import '../data/models/expense.dart';
import '../data/models/house_rule.dart';
import '../data/models/member.dart';
import '../data/models/swap_request.dart';
import '../data/repositories/app_repository.dart';

/// Tenant-side app state: chores, swaps, rules, expenses and fairness numbers.
/// Screens read from here and call its methods; it saves through [AppRepository].
class HouseholdState extends ChangeNotifier {
  HouseholdState(this._repository);

  final AppRepository _repository;

  bool loaded = false;
  String householdName = '';
  String inviteCode = '';
  String currentUserId = '';
  List<Member> members = <Member>[];
  List<Chore> chores = <Chore>[];
  List<SwapRequest> swaps = <SwapRequest>[];
  List<ActivityItem> activity = <ActivityItem>[];
  List<HouseRule> rules = <HouseRule>[];
  List<Expense> expenses = <Expense>[];
  Map<String, int> doneThisWeek = <String, int>{};
  Map<String, int> streakWeeks = <String, int>{};
  int totalChoresThisWeek = 0;

  bool autoRotate = true;
  bool choreReminders = true;
  bool swapNotifications = true;
  bool weeklyRecapNotifications = false;

  int _idCounter = 0;

  Future<void> load() async {
    final snapshot = await _repository.loadHousehold();
    householdName = snapshot.householdName;
    inviteCode = snapshot.inviteCode;
    currentUserId = snapshot.currentUserId;
    members = List<Member>.from(snapshot.members);
    chores = List<Chore>.from(snapshot.chores);
    swaps = List<SwapRequest>.from(snapshot.swaps);
    activity = List<ActivityItem>.from(snapshot.activity);
    rules = List<HouseRule>.from(snapshot.rules);
    expenses = List<Expense>.from(snapshot.expenses);
    doneThisWeek = Map<String, int>.from(snapshot.doneThisWeek);
    streakWeeks = Map<String, int>.from(snapshot.streakWeeks);
    totalChoresThisWeek = snapshot.totalChoresThisWeek;
    loaded = true;
    notifyListeners();
  }

  // ---------- lookups ----------

  Member memberById(String id) {
    return members.firstWhere((m) => m.id == id, orElse: () => members.first);
  }

  Member get currentUser => memberById(currentUserId);

  // ---------- members ----------

  /// Adds a new person to the household (used when a tenant signs up with the invite code).
  Member addMember(String name) {
    _idCounter += 1;
    const colors = MemberColor.values;
    final member = Member(id: 'm-new-$_idCounter', name: name.trim(), color: colors[members.length % colors.length]);
    members = [...members, member];
    doneThisWeek[member.id] = 0;
    streakWeeks[member.id] = 0;
    notifyListeners();
    return member;
  }

  void renameMember(String id, String name) {
    members = [
      for (final m in members) m.id == id ? Member(id: m.id, name: name.trim(), color: m.color) : m,
    ];
    notifyListeners();
  }

  void removeMember(String id) {
    members = members.where((m) => m.id != id).toList();
    doneThisWeek.remove(id);
    streakWeeks.remove(id);
    notifyListeners();
  }

  void setCurrentUser(String memberId) {
    currentUserId = memberId;
    notifyListeners();
  }

  // ---------- chores ----------

  int get choresDone => chores.where((c) => c.isDone).length;
  int get choresLeft => chores.length - choresDone;

  /// Chores assigned to the current user that are not done yet, overdue first.
  List<Chore> get myOpenChores {
    final list = chores.where((c) => c.assigneeId == currentUserId && !c.isDone).toList();
    list.sort((a, b) {
      final aOver = a.status == ChoreStatus.overdue ? 0 : 1;
      final bOver = b.status == ChoreStatus.overdue ? 0 : 1;
      return aOver.compareTo(bOver);
    });
    return list;
  }

  Chore? get firstOverdueChore {
    for (final c in chores) {
      if (c.status == ChoreStatus.overdue) return c;
    }
    return null;
  }

  Chore? choreById(String id) {
    for (final c in chores) {
      if (c.id == id) return c;
    }
    return null;
  }

  void markChoreDone(String choreId) {
    final index = chores.indexWhere((c) => c.id == choreId);
    if (index < 0 || chores[index].isDone) return;
    final updated = chores[index].copyWith(status: ChoreStatus.done, completedAt: DateTime.now());
    chores[index] = updated;
    doneThisWeek[updated.assigneeId] = (doneThisWeek[updated.assigneeId] ?? 0) + 1;
    activity.insert(
      0,
      ActivityItem(
        id: _newId('a'),
        memberId: updated.assigneeId,
        message: 'finished ${updated.name}',
        timeLabel: _clock(DateTime.now()),
        isToday: true,
      ),
    );
    _repository.saveChore(updated);
    notifyListeners();
  }

  void addChore({
    required String name,
    required Frequency frequency,
    required Difficulty difficulty,
    required String assigneeId,
  }) {
    final chore = Chore(
      id: _newId('c'),
      name: name,
      assigneeId: assigneeId,
      day: 'Today',
      dueFull: 'Today',
      status: ChoreStatus.todo,
      iconKey: 'sparkle',
      difficulty: difficulty,
      frequency: frequency,
    );
    chores.add(chore);
    totalChoresThisWeek += 1;
    _repository.saveChore(chore);
    notifyListeners();
  }

  /// Who gets a new chore in each of the next [weeks] weeks: starts with the member
  /// who has done the fewest chores, then follows the household order.
  List<Member> rotationPreview({int weeks = 4}) {
    if (members.isEmpty) return <Member>[];
    var startIndex = 0;
    var lowest = 1 << 30;
    for (var i = 0; i < members.length; i++) {
      final done = doneThisWeek[members[i].id] ?? 0;
      if (done < lowest) {
        lowest = done;
        startIndex = i;
      }
    }
    final result = <Member>[];
    for (var w = 0; w < weeks; w++) {
      result.add(members[(startIndex + w) % members.length]);
    }
    return result;
  }

  // ---------- fairness ----------

  int get totalDone => doneThisWeek.values.fold(0, (a, b) => a + b);

  /// Share of completed chores for one member, 0 to 100.
  int sharePercent(String memberId) {
    if (totalDone == 0) return 0;
    return ((doneThisWeek[memberId] ?? 0) * 100 / totalDone).round();
  }

  /// Fairness score from 0 to 100: 100 minus 100 times the Gini coefficient of
  /// chores done. 100 means everyone did the same amount.
  int get fairnessScore {
    final values = members.map((m) => doneThisWeek[m.id] ?? 0).toList();
    final n = values.length;
    final sum = values.fold(0, (a, b) => a + b);
    if (n == 0 || sum == 0) return 100;
    var diffSum = 0;
    for (final a in values) {
      for (final b in values) {
        diffSum += (a - b).abs();
      }
    }
    final gini = diffSum / (2 * n * sum);
    return (100 * (1 - gini)).round();
  }

  String get fairnessLabel {
    final score = fairnessScore;
    if (score >= 80) return 'Nicely balanced';
    if (score >= 50) return 'Room to balance things out';
    return 'Time for a quick chat';
  }

  Member? get topContributor {
    Member? best;
    var bestCount = -1;
    for (final m in members) {
      final count = doneThisWeek[m.id] ?? 0;
      if (count > bestCount) {
        best = m;
        bestCount = count;
      }
    }
    return best;
  }

  // ---------- swaps ----------

  List<SwapRequest> get incomingSwaps =>
      swaps.where((s) => s.targetId == currentUserId && s.status == SwapStatus.pending).toList();

  List<SwapRequest> get sentSwaps => swaps.where((s) => s.requesterId == currentUserId).toList();

  void resolveSwap(String swapId, SwapStatus status) {
    final index = swaps.indexWhere((s) => s.id == swapId);
    if (index < 0) return;
    swaps[index] = swaps[index].copyWith(status: status);
    _repository.saveSwap(swaps[index]);
    notifyListeners();
  }

  void requestCoverage({required String choreName, required String targetId, required String reason}) {
    final swap = SwapRequest(
      id: _newId('s'),
      requesterId: currentUserId,
      targetId: targetId,
      offeredChore: choreName,
      reason: reason,
    );
    swaps.add(swap);
    _repository.saveSwap(swap);
    notifyListeners();
  }

  // ---------- rules ----------

  void addRule(String text) {
    final rule = HouseRule(id: _newId('r'), text: text);
    rules.add(rule);
    _repository.saveRule(rule);
    notifyListeners();
  }

  // ---------- quick split ----------

  void addExpense({required String title, required int amountCentavos, required String payerId}) {
    final expense = Expense(
      id: _newId('e'),
      title: title,
      amountCentavos: amountCentavos,
      payerId: payerId,
      participantIds: members.map((m) => m.id).toList(),
      createdAt: DateTime.now(),
    );
    expenses.add(expense);
    _repository.saveExpense(expense);
    notifyListeners();
  }

  /// Net balance per member across all expenses (positive = is owed money).
  Map<String, int> get balances {
    final result = <String, int>{for (final m in members) m.id: 0};
    for (final e in expenses) {
      final shares = SplitCalculator.equalShares(e.amountCentavos, e.participantIds);
      shares.forEach((id, share) {
        result[id] = (result[id] ?? 0) - share;
      });
      result[e.payerId] = (result[e.payerId] ?? 0) + e.amountCentavos;
    }
    return result;
  }

  // ---------- settings ----------

  void setAutoRotate(bool value) {
    autoRotate = value;
    notifyListeners();
  }

  void setChoreReminders(bool value) {
    choreReminders = value;
    notifyListeners();
  }

  void setSwapNotifications(bool value) {
    swapNotifications = value;
    notifyListeners();
  }

  void setWeeklyRecapNotifications(bool value) {
    weeklyRecapNotifications = value;
    notifyListeners();
  }

  // ---------- helpers ----------

  String _newId(String prefix) {
    _idCounter += 1;
    return '$prefix-new-$_idCounter';
  }

  String _clock(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
