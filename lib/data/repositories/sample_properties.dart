import '../models/landlord_models.dart';
import '../models/member.dart';
import 'app_repository.dart';

/// TEMPORARY sample boarding houses for the landlord side (3 properties, 30 rooms,
/// 24 tenants). Replace by loading real data in your own AppRepository.
class SampleProperties {
  SampleProperties._();

  // Extra tenants (the first four tenants of Lakbay come from the tenant-side household).
  static const Member elena = Member(id: 'elena', name: 'Elena', color: MemberColor.lime);
  static const Member gabriel = Member(id: 'gabriel', name: 'Gabriel', color: MemberColor.blue);
  static const Member lia = Member(id: 'lia', name: 'Lia', color: MemberColor.pink);
  static const Member marco = Member(id: 'marco', name: 'Marco', color: MemberColor.blue);
  static const Member rico = Member(id: 'rico', name: 'Rico', color: MemberColor.lime);
  static const Member tessa = Member(id: 'tessa', name: 'Tessa', color: MemberColor.navy);
  static const Member noel = Member(id: 'noel', name: 'Noel', color: MemberColor.pink);
  static const Member bea = Member(id: 'bea', name: 'Bea', color: MemberColor.blue);
  static const Member jun = Member(id: 'jun', name: 'Jun', color: MemberColor.lime);
  static const Member mika = Member(id: 'mika', name: 'Mika', color: MemberColor.navy);
  static const Member paolo = Member(id: 'paolo', name: 'Paolo', color: MemberColor.pink);
  static const Member rhea = Member(id: 'rhea', name: 'Rhea', color: MemberColor.blue);
  static const Member sam = Member(id: 'sam', name: 'Sam', color: MemberColor.lime);
  static const Member tina = Member(id: 'tina', name: 'Tina', color: MemberColor.navy);
  static const Member vince = Member(id: 'vince', name: 'Vince', color: MemberColor.pink);
  static const Member wendy = Member(id: 'wendy', name: 'Wendy', color: MemberColor.blue);
  static const Member yani = Member(id: 'yani', name: 'Yani', color: MemberColor.lime);
  static const Member zoe = Member(id: 'zoe', name: 'Zoe', color: MemberColor.navy);
  static const Member andre = Member(id: 'andre', name: 'Andre', color: MemberColor.pink);

  static const List<RuleTemplate> _templates = [
    RuleTemplate(id: 't1', title: 'Quiet hours', subtitle: 'Quiet after 10 PM'),
    RuleTemplate(id: 't2', title: 'Shared spaces', subtitle: 'Keep shared areas tidy'),
    RuleTemplate(id: 't3', title: 'Guest policy', subtitle: 'Visitors sign in'),
  ];

  /// All sample properties. The first one is the mockup's "Lakbay Boarding House".
  static List<PropertySnapshot> all({
    required Member ana,
    required Member ben,
    required Member carlo,
    required Member dani,
  }) {
    return [
      _build(
        id: 'lakbay',
        name: 'Lakbay Boarding House',
        code: 'LKB-482',
        rentCentavos: 800000,
        rooms: [
          _Seed(ana, RentStatus.paid, 1),
          _Seed(ben, RentStatus.late, 5),
          _Seed(carlo, RentStatus.paid, 1),
          _Seed(dani, RentStatus.paid, 1),
          _Seed(elena, RentStatus.paid, 3),
          _Seed(gabriel, RentStatus.paid, 1),
          const _Seed(null, RentStatus.vacant, 1),
          const _Seed(null, RentStatus.vacant, 1),
        ],
        repairs: const [
          RepairRequest(id: 'lk-rp1', title: 'Leaking tap', detail: 'Room 3 · Carlo · Oct 20', stage: RepairStage.reported),
          RepairRequest(id: 'lk-rp2', title: 'Window latch', detail: 'Room 1 · Ana · Oct 18', stage: RepairStage.inProgress),
          RepairRequest(id: 'lk-rp3', title: 'Hallway light', detail: 'Room 4 · Fixed Oct 16', stage: RepairStage.fixed),
        ],
        notices: const [
          Notice(id: 'lk-n1', title: 'Water interruption', dateLabel: 'Oct 18 · All tenants', body: 'Water service will be paused tomorrow, 9 AM–12 PM, for tank cleaning.'),
          Notice(id: 'lk-n2', title: 'Quiet hours reminder', dateLabel: 'Oct 12 · All tenants', body: 'Please keep shared spaces quiet after 10 PM. Thank you!'),
        ],
        activity: const ['Ana paid rent for Room 1', 'Elena paid rent for Room 5', 'Gabriel paid rent for Room 6'],
      ),
      _build(
        id: 'sampaguita',
        name: 'Sampaguita Residences',
        code: 'SMP-317',
        rentCentavos: 650000,
        rooms: [
          _Seed(lia, RentStatus.paid, 1),
          _Seed(marco, RentStatus.paid, 1),
          _Seed(rico, RentStatus.late, 3),
          _Seed(tessa, RentStatus.paid, 1),
          _Seed(noel, RentStatus.late, 8),
          _Seed(bea, RentStatus.paid, 2),
          _Seed(jun, RentStatus.paid, 1),
          _Seed(mika, RentStatus.paid, 5),
          const _Seed(null, RentStatus.vacant, 1),
          const _Seed(null, RentStatus.vacant, 1),
        ],
        repairs: const [
          RepairRequest(id: 'sm-rp1', title: 'Broken faucet', detail: 'Room 4 · Tessa · Oct 21', stage: RepairStage.reported),
          RepairRequest(id: 'sm-rp2', title: 'Aircon cleaning', detail: 'Room 2 · Marco · Oct 19', stage: RepairStage.inProgress),
          RepairRequest(id: 'sm-rp3', title: 'Gate lock', detail: 'Room 6 · Fixed Oct 14', stage: RepairStage.fixed),
        ],
        notices: const [
          Notice(id: 'sm-n1', title: 'Gate hours', dateLabel: 'Oct 20 · All tenants', body: 'The main gate closes at 11 PM. Please bring your key if you will be late.'),
          Notice(id: 'sm-n2', title: 'Garbage collection', dateLabel: 'Oct 15 · All tenants', body: 'Garbage is collected every Tuesday and Friday morning. Bag it by 7 AM.'),
        ],
        activity: const ['Lia paid rent for Room 1', 'Marco paid rent for Room 2', 'Tessa paid rent for Room 4'],
      ),
      _build(
        id: 'mabini',
        name: 'Mabini Dormitory',
        code: 'MBN-905',
        rentCentavos: 500000,
        rooms: [
          _Seed(paolo, RentStatus.paid, 1),
          _Seed(rhea, RentStatus.paid, 1),
          _Seed(sam, RentStatus.late, 4),
          _Seed(tina, RentStatus.paid, 2),
          _Seed(vince, RentStatus.paid, 1),
          _Seed(wendy, RentStatus.paid, 1),
          _Seed(yani, RentStatus.paid, 6),
          _Seed(zoe, RentStatus.late, 7),
          _Seed(andre, RentStatus.paid, 1),
          const _Seed(null, RentStatus.vacant, 1),
          const _Seed(null, RentStatus.vacant, 1),
          const _Seed(null, RentStatus.vacant, 1),
        ],
        repairs: const [
          RepairRequest(id: 'mb-rp1', title: 'Ceiling leak', detail: 'Room 7 · Yani · Oct 22', stage: RepairStage.reported),
          RepairRequest(id: 'mb-rp2', title: 'Wi-Fi router', detail: 'Room 2 · Rhea · Oct 20', stage: RepairStage.inProgress),
          RepairRequest(id: 'mb-rp3', title: 'Window screen', detail: 'Room 5 · Fixed Oct 13', stage: RepairStage.fixed),
        ],
        notices: const [
          Notice(id: 'mb-n1', title: 'Visitor hours', dateLabel: 'Oct 19 · All tenants', body: 'Visitors are welcome until 9 PM and must register at the front desk.'),
          Notice(id: 'mb-n2', title: 'Water tank cleaning', dateLabel: 'Oct 10 · All tenants', body: 'The water tank will be cleaned on Saturday. Expect a short interruption.'),
        ],
        activity: const ['Paolo paid rent for Room 1', 'Rhea paid rent for Room 2', 'Andre paid rent for Room 9'],
      ),
    ];
  }

  static PropertySnapshot _build({
    required String id,
    required String name,
    required String code,
    required int rentCentavos,
    required List<_Seed> rooms,
    required List<RepairRequest> repairs,
    required List<Notice> notices,
    required List<String> activity,
  }) {
    final roomList = <Room>[];
    final rent = <RentRecord>[];
    final acceptances = <Acceptance>[];
    var occupied = 0;
    for (var i = 0; i < rooms.length; i++) {
      final seed = rooms[i];
      final number = i + 1;
      final tenant = seed.tenant;
      if (tenant == null) {
        roomList.add(Room(number: number, status: RentStatus.vacant, subtitle: 'Ready to rent'));
        continue;
      }
      occupied += 1;
      final paid = seed.status == RentStatus.paid;
      roomList.add(Room(
        number: number,
        tenant: tenant,
        status: seed.status,
        subtitle: paid ? 'Paid · through Oct 31' : 'Rent due Oct ${seed.dueDay}',
      ));
      rent.add(RentRecord(
        id: '$id-rt$number',
        roomNumber: number,
        tenant: tenant,
        amountCentavos: rentCentavos,
        dueLabel: 'Due Oct ${seed.dueDay}',
        status: seed.status,
      ));
      acceptances.add(Acceptance(tenant: tenant, accepted: occupied.isOdd));
    }
    final firstTenant = rooms.firstWhere((s) => s.tenant != null);
    final firstNumber = rooms.indexOf(firstTenant) + 1;
    rent.add(RentRecord(
      id: '$id-next',
      roomNumber: firstNumber,
      tenant: firstTenant.tenant!,
      amountCentavos: rentCentavos,
      dueLabel: 'Due Nov 1',
      status: RentStatus.due,
      isCurrentMonth: false,
    ));
    return PropertySnapshot(
      id: id,
      propertyName: name,
      inviteCode: code,
      rooms: roomList,
      rent: rent,
      repairs: repairs,
      notices: notices,
      templates: _templates,
      acceptances: acceptances,
      recentActivity: activity,
    );
  }
}

class _Seed {
  const _Seed(this.tenant, this.status, this.dueDay);
  final Member? tenant;
  final RentStatus status;
  final int dueDay;
}
