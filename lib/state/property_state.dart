import 'package:flutter/foundation.dart';

import '../data/models/landlord_models.dart';
import '../data/repositories/app_repository.dart';

/// Landlord-side app state: rooms, rent, repairs, notices and rule templates.
/// It never touches the tenants' chores or expenses (privacy rule of the product).
class PropertyState extends ChangeNotifier {
  PropertyState(this._repository);

  final AppRepository _repository;

  bool loaded = false;

  final List<_PropertyData> _all = <_PropertyData>[];
  int _selected = 0;

  /// Names of all properties, for the property picker.
  List<String> get propertyNames => _all.map((p) => p.name).toList();
  List<int> get propertyRoomCounts => _all.map((p) => p.rooms.length).toList();
  int get propertyCount => _all.length;
  int get selectedIndex => _selected;

  _PropertyData get _current => _all.isEmpty ? _empty : _all[_selected];
  static final _PropertyData _empty = _PropertyData.empty();

  // The screens read these for the property that is currently selected.
  String get propertyName => _current.name;
  String get inviteCode => _current.inviteCode;
  List<Room> get rooms => _current.rooms;
  List<RentRecord> get rent => _current.rent;
  List<RepairRequest> get repairs => _current.repairs;
  List<Notice> get notices => _current.notices;
  List<RuleTemplate> get templates => _current.templates;
  List<Acceptance> get acceptances => _current.acceptances;
  set acceptances(List<Acceptance> value) => _current.acceptances = value;
  List<String> get recentActivity => _current.recentActivity;
  String get selectedTemplateId => _current.selectedTemplateId;
  set selectedTemplateId(String value) => _current.selectedTemplateId = value;

  int _idCounter = 0;

  Future<void> load() async {
    final snapshots = await _repository.loadProperties();
    _all
      ..clear()
      ..addAll(snapshots.map(_PropertyData.fromSnapshot));
    _selected = 0;
    loaded = true;
    notifyListeners();
  }

  /// Switches the whole landlord side to another boarding house.
  void selectProperty(int index) {
    if (index < 0 || index >= _all.length || index == _selected) return;
    _selected = index;
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

/// Editable copy of one boarding house's data.
class _PropertyData {
  _PropertyData({
    required this.name,
    required this.inviteCode,
    required this.rooms,
    required this.rent,
    required this.repairs,
    required this.notices,
    required this.templates,
    required this.acceptances,
    required this.recentActivity,
  });

  factory _PropertyData.fromSnapshot(PropertySnapshot s) {
    return _PropertyData(
      name: s.propertyName,
      inviteCode: s.inviteCode,
      rooms: List<Room>.from(s.rooms),
      rent: List<RentRecord>.from(s.rent),
      repairs: List<RepairRequest>.from(s.repairs),
      notices: List<Notice>.from(s.notices),
      templates: List<RuleTemplate>.from(s.templates),
      acceptances: List<Acceptance>.from(s.acceptances),
      recentActivity: List<String>.from(s.recentActivity),
    );
  }

  factory _PropertyData.empty() {
    return _PropertyData(
      name: '',
      inviteCode: '',
      rooms: <Room>[],
      rent: <RentRecord>[],
      repairs: <RepairRequest>[],
      notices: <Notice>[],
      templates: <RuleTemplate>[],
      acceptances: <Acceptance>[],
      recentActivity: <String>[],
    );
  }

  final String name;
  final String inviteCode;
  final List<Room> rooms;
  final List<RentRecord> rent;
  final List<RepairRequest> repairs;
  final List<Notice> notices;
  final List<RuleTemplate> templates;
  List<Acceptance> acceptances;
  final List<String> recentActivity;
  String selectedTemplateId = 't1';
}
