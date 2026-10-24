import 'package:flutter/foundation.dart';

import '../data/models/landlord_models.dart';
import '../data/repositories/app_repository.dart';

/// Landlord-side app state: rooms, rent, repairs, notices and rule templates.
/// It never touches the tenants' chores or expenses (privacy rule of the product).
class PropertyState extends ChangeNotifier {
  PropertyState(this._repository);

  final AppRepository _repository;

  bool loaded = false;
  String propertyName = '';
  String inviteCode = '';
  List<Room> rooms = <Room>[];
  List<RentRecord> rent = <RentRecord>[];
  List<RepairRequest> repairs = <RepairRequest>[];
  List<Notice> notices = <Notice>[];
  List<RuleTemplate> templates = <RuleTemplate>[];
  List<Acceptance> acceptances = <Acceptance>[];
  List<String> recentActivity = <String>[];
  String selectedTemplateId = 't1';

  int _idCounter = 0;

  Future<void> load() async {
    final snapshot = await _repository.loadProperty();
    propertyName = snapshot.propertyName;
    inviteCode = snapshot.inviteCode;
    rooms = List<Room>.from(snapshot.rooms);
    rent = List<RentRecord>.from(snapshot.rent);
    repairs = List<RepairRequest>.from(snapshot.repairs);
    notices = List<Notice>.from(snapshot.notices);
    templates = List<RuleTemplate>.from(snapshot.templates);
    acceptances = List<Acceptance>.from(snapshot.acceptances);
    recentActivity = List<String>.from(snapshot.recentActivity);
    loaded = true;
    notifyListeners();
  }

  // ---------- rooms ----------

  int get roomCount => rooms.length;
  int get occupiedCount => rooms.where((r) => !r.isVacant).length;
  int get availableCount => roomCount - occupiedCount;

  // ---------- rent ----------

  List<RentRecord> get monthlyRent => rent.where((r) => r.isCurrentMonth).toList();
  List<RentRecord> get upcomingRent => rent.where((r) => !r.isCurrentMonth).toList();

  int get paidCount => monthlyRent.where((r) => r.status == RentStatus.paid).length;
  int get lateCount => monthlyRent.where((r) => r.status == RentStatus.late).length;
  int get expectedCentavos => monthlyRent.fold(0, (a, r) => a + r.amountCentavos);
  int get collectedCentavos =>
      monthlyRent.where((r) => r.status == RentStatus.paid).fold(0, (a, r) => a + r.amountCentavos);

  RentRecord? get firstLate {
    for (final r in monthlyRent) {
      if (r.status == RentStatus.late) return r;
    }
    return null;
  }

  void markRentReceived(String recordId) {
    final index = rent.indexWhere((r) => r.id == recordId);
    if (index < 0) return;
    final updated = rent[index].copyWith(status: RentStatus.paid);
    rent[index] = updated;
    final roomIndex = rooms.indexWhere((r) => r.number == updated.roomNumber);
    if (roomIndex >= 0) {
      rooms[roomIndex] = rooms[roomIndex].copyWith(status: RentStatus.paid, subtitle: 'Paid · through Oct 31');
    }
    recentActivity.insert(0, '${updated.tenant.name} paid rent for Room ${updated.roomNumber}');
    _repository.saveRent(updated);
    notifyListeners();
  }

  // ---------- repairs ----------

  int get openRepairCount => repairs.where((r) => r.stage != RepairStage.fixed).length;
  List<RepairRequest> get openRepairs => repairs.where((r) => r.stage != RepairStage.fixed).toList();
  List<RepairRequest> get fixedRepairs => repairs.where((r) => r.stage == RepairStage.fixed).toList();

  void advanceRepair(String repairId) {
    final index = repairs.indexWhere((r) => r.id == repairId);
    if (index < 0) return;
    final current = repairs[index].stage;
    final next = current == RepairStage.reported ? RepairStage.inProgress : RepairStage.fixed;
    if (current == RepairStage.fixed) return;
    repairs[index] = repairs[index].copyWith(stage: next);
    _repository.saveRepair(repairs[index]);
    notifyListeners();
  }

  // ---------- notices ----------

  void sendNotice(String body) {
    final text = body.trim();
    if (text.isEmpty) return;
    final notice = Notice(
      id: _newId('n'),
      title: text.length > 28 ? '${text.substring(0, 28)}...' : text,
      dateLabel: 'Just now · All tenants',
      body: text,
    );
    notices.insert(0, notice);
    _repository.saveNotice(notice);
    notifyListeners();
  }

  // ---------- rule templates ----------

  void selectTemplate(String id) {
    selectedTemplateId = id;
    notifyListeners();
  }

  /// Marks every tenant as "pending" for the newly sent template.
  void sendTemplateToTenants() {
    acceptances = acceptances.map((a) => Acceptance(tenant: a.tenant, accepted: false)).toList();
    notifyListeners();
  }

  String _newId(String prefix) {
    _idCounter += 1;
    return '$prefix-new-$_idCounter';
  }
}
