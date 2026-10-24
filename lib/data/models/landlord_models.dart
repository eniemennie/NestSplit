import 'member.dart';

enum RentStatus { paid, late, due, vacant }

/// A room in the landlord's property.
class Room {
  const Room({
    required this.number,
    required this.status,
    required this.subtitle,
    this.tenant,
  });

  final int number;
  final RentStatus status;
  final String subtitle;
  final Member? tenant;

  bool get isVacant => tenant == null;

  Room copyWith({RentStatus? status, String? subtitle}) {
    return Room(
      number: number,
      status: status ?? this.status,
      subtitle: subtitle ?? this.subtitle,
      tenant: tenant,
    );
  }
}

/// One line in the monthly rent list. Amounts are whole centavos.
class RentRecord {
  const RentRecord({
    required this.id,
    required this.roomNumber,
    required this.tenant,
    required this.amountCentavos,
    required this.dueLabel,
    required this.status,
    this.isCurrentMonth = true,
  });

  final String id;
  final int roomNumber;
  final Member tenant;
  final int amountCentavos;
  final String dueLabel;
  final RentStatus status;
  final bool isCurrentMonth;

  RentRecord copyWith({RentStatus? status}) {
    return RentRecord(
      id: id,
      roomNumber: roomNumber,
      tenant: tenant,
      amountCentavos: amountCentavos,
      dueLabel: dueLabel,
      status: status ?? this.status,
      isCurrentMonth: isCurrentMonth,
    );
  }
}

enum RepairStage { reported, inProgress, fixed }

class RepairRequest {
  const RepairRequest({
    required this.id,
    required this.title,
    required this.detail,
    required this.stage,
  });

  final String id;
  final String title;

  /// e.g. "Room 3 · Carlo · Oct 20".
  final String detail;
  final RepairStage stage;

  RepairRequest copyWith({RepairStage? stage}) {
    return RepairRequest(id: id, title: title, detail: detail, stage: stage ?? this.stage);
  }
}

class Notice {
  const Notice({required this.id, required this.title, required this.dateLabel, required this.body});
  final String id;
  final String title;
  final String dateLabel;
  final String body;
}

class RuleTemplate {
  const RuleTemplate({required this.id, required this.title, required this.subtitle});
  final String id;
  final String title;
  final String subtitle;
}

/// Whether a tenant accepted the rule template the landlord sent.
class Acceptance {
  const Acceptance({required this.tenant, required this.accepted});
  final Member tenant;
  final bool accepted;
}
