import 'dart:convert';

/// Soft chat bubble fills — assigned to members when created/added.
class SplitMemberColors {
  static const List<int> palette = [
    0xFFD9F5EF, // mint
    0xFFFFE0C2, // peach
    0xFFDCE4FF, // periwinkle
    0xFFFFD6E7, // pink
    0xFFDFF5E1, // green
    0xFFFFF0B3, // yellow
    0xFFD6EEFF, // sky
    0xFFE8D9F5, // lavender
    0xFFFFD9D6, // coral
    0xFFD4F4F0, // aqua
  ];

  static int nextFor(List<SplitMember> existing) {
    final used = existing.map((m) => m.colorValue).where((c) => c != 0).toSet();
    for (final c in palette) {
      if (!used.contains(c)) return c;
    }
    return palette[existing.length % palette.length];
  }

  /// Fill in any members missing a color (legacy data).
  static bool ensureGroup(SplitGroup group) {
    var changed = false;
    for (var i = 0; i < group.members.length; i++) {
      final m = group.members[i];
      if (m.colorValue == 0) {
        m.colorValue = nextFor(group.members.where((x) => x.colorValue != 0).toList());
        changed = true;
      }
    }
    return changed;
  }
}

class SplitMember {
  final String id;
  String name;
  String phone;
  /// ARGB chat/avatar color for this member in the group.
  int colorValue;

  SplitMember({
    required this.id,
    required this.name,
    this.phone = '',
    this.colorValue = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'colorValue': colorValue,
      };

  factory SplitMember.fromJson(Map<String, dynamic> j) => SplitMember(
        id: j['id'] as String,
        name: j['name'] as String,
        phone: j['phone'] as String? ?? '',
        colorValue: (j['colorValue'] as num?)?.toInt() ?? 0,
      );
}

/// One payment in chat: who paid, and which members share the bill.
class SplitExpense {
  final String id;
  double amount;
  String note;
  DateTime createdAt;
  DateTime? remindAt;
  String paidById;
  String paidByName;
  String paidForId;
  String paidForName;
  /// Members this amount is split among (subset of group).
  List<String> splitAmongIds;
  List<String> splitAmongNames;
  bool settled;
  bool expanded;

  SplitExpense({
    required this.id,
    required this.amount,
    required this.note,
    required this.createdAt,
    this.remindAt,
    required this.paidById,
    required this.paidByName,
    required this.paidForId,
    required this.paidForName,
    List<String>? splitAmongIds,
    List<String>? splitAmongNames,
    this.settled = false,
    this.expanded = true,
  })  : splitAmongIds = splitAmongIds ?? const [],
        splitAmongNames = splitAmongNames ?? const [];

  /// Self-pay / legacy flag — settlement now uses equal share of unpaid bills.
  bool get createsDebt => true;

  int get splitCount =>
      splitAmongIds.isEmpty ? 1 : splitAmongIds.length;

  double get shareEach => amount / splitCount;

  String get splitAmongLabel {
    final names = splitAmongNames;
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]} & ${names[1]}';
    return '${names.sublist(0, names.length - 1).join(', ')} & ${names.last}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'remindAt': remindAt?.toIso8601String(),
        'paidById': paidById,
        'paidByName': paidByName,
        'paidForId': paidForId,
        'paidForName': paidForName,
        'splitAmongIds': splitAmongIds,
        'splitAmongNames': splitAmongNames,
        'settled': settled,
        'expanded': expanded,
      };

  factory SplitExpense.fromJson(Map<String, dynamic> j) {
    // Migrate old multi-share expenses if present.
    if (j['paidForId'] == null && j['shares'] is List) {
      final shares = j['shares'] as List;
      final first = shares.isNotEmpty
          ? Map<String, dynamic>.from(shares.first as Map)
          : null;
      final amongIds = <String>[];
      final amongNames = <String>[];
      for (final s in shares) {
        final m = Map<String, dynamic>.from(s as Map);
        final id = m['memberId'] as String?;
        final name = m['memberName'] as String?;
        if (id != null) {
          amongIds.add(id);
          amongNames.add(name ?? id);
        }
      }
      return SplitExpense(
        id: j['id'] as String,
        amount: (j['amount'] as num).toDouble(),
        note: j['note'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        remindAt: j['remindAt'] != null
            ? DateTime.tryParse(j['remindAt'] as String)
            : null,
        paidById: 'you',
        paidByName: j['paidByName'] as String? ?? 'You',
        paidForId: first?['memberId'] as String? ?? 'you',
        paidForName: first?['memberName'] as String? ?? 'You',
        splitAmongIds: amongIds,
        splitAmongNames: amongNames,
        settled: first?['settled'] as bool? ?? false,
        expanded: j['expanded'] as bool? ?? true,
      );
    }

    final amongIds = (j['splitAmongIds'] as List? ?? [])
        .map((e) => e.toString())
        .toList();
    final amongNames = (j['splitAmongNames'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    // Legacy: no splitAmong → treat as paid-for person only / whole bill on payer.
    final paidForId = j['paidForId'] as String? ?? 'you';
    final paidForName = j['paidForName'] as String? ?? 'You';

    return SplitExpense(
      id: j['id'] as String,
      amount: (j['amount'] as num).toDouble(),
      note: j['note'] as String? ?? '',
      createdAt: DateTime.parse(j['createdAt'] as String),
      remindAt: j['remindAt'] != null
          ? DateTime.tryParse(j['remindAt'] as String)
          : null,
      paidById: j['paidById'] as String? ?? 'you',
      paidByName: j['paidByName'] as String? ?? 'You',
      paidForId: paidForId,
      paidForName: paidForName,
      splitAmongIds: amongIds.isNotEmpty ? amongIds : [paidForId],
      splitAmongNames: amongNames.isNotEmpty ? amongNames : [paidForName],
      settled: j['settled'] as bool? ?? false,
      expanded: j['expanded'] as bool? ?? true,
    );
  }
}

/// Net: positive = they should receive, negative = they should pay.
class SettlementLine {
  final String memberId;
  final String memberName;
  final double net;

  const SettlementLine({
    required this.memberId,
    required this.memberName,
    required this.net,
  });

  bool get isZero => net.abs() < 0.01;

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'memberName': memberName,
        'net': net,
      };

  factory SettlementLine.fromJson(Map<String, dynamic> j) => SettlementLine(
        memberId: j['memberId'] as String,
        memberName: j['memberName'] as String,
        net: (j['net'] as num).toDouble(),
      );
}

/// "A should pay B this amount" after simplifying nets.
class SettlementTransfer {
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final double amount;

  const SettlementTransfer({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'fromId': fromId,
        'fromName': fromName,
        'toId': toId,
        'toName': toName,
        'amount': amount,
      };

  factory SettlementTransfer.fromJson(Map<String, dynamic> j) =>
      SettlementTransfer(
        fromId: j['fromId'] as String,
        fromName: j['fromName'] as String,
        toId: j['toId'] as String,
        toName: j['toName'] as String,
        amount: (j['amount'] as num).toDouble(),
      );

  /// Greedy settle: debtors pay creditors until nets clear.
  static List<SettlementTransfer> fromNets(List<SettlementLine> lines) {
    final debtors = lines
        .where((l) => l.net < -0.009)
        .map((l) => MapEntry(l, -l.net))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final creditors = lines
        .where((l) => l.net > 0.009)
        .map((l) => MapEntry(l, l.net))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final out = <SettlementTransfer>[];
    var i = 0;
    var j = 0;
    while (i < debtors.length && j < creditors.length) {
      final pay = debtors[i].value < creditors[j].value
          ? debtors[i].value
          : creditors[j].value;
      final amt = double.parse(pay.toStringAsFixed(2));
      if (amt >= 0.01) {
        out.add(
          SettlementTransfer(
            fromId: debtors[i].key.memberId,
            fromName: debtors[i].key.memberName,
            toId: creditors[j].key.memberId,
            toName: creditors[j].key.memberName,
            amount: amt,
          ),
        );
      }
      debtors[i] = MapEntry(debtors[i].key, debtors[i].value - pay);
      creditors[j] = MapEntry(creditors[j].key, creditors[j].value - pay);
      if (debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }
    return out;
  }
}

/// How much one member paid across pending bills.
class MemberPaidTotal {
  final String memberId;
  final String memberName;
  final double totalPaid;
  final int billCount;

  const MemberPaidTotal({
    required this.memberId,
    required this.memberName,
    required this.totalPaid,
    required this.billCount,
  });

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'memberName': memberName,
        'totalPaid': totalPaid,
        'billCount': billCount,
      };

  factory MemberPaidTotal.fromJson(Map<String, dynamic> j) => MemberPaidTotal(
        memberId: j['memberId'] as String,
        memberName: j['memberName'] as String,
        totalPaid: (j['totalPaid'] as num).toDouble(),
        billCount: (j['billCount'] as num?)?.toInt() ?? 0,
      );
}

/// Snapshot of one pending bill at settle time.
class SettlementBillSnap {
  final String expenseId;
  final double amount;
  final String note;
  final DateTime createdAt;
  final String paidByName;
  final List<String> amongNames;
  final double shareEach;

  const SettlementBillSnap({
    required this.expenseId,
    required this.amount,
    required this.note,
    required this.createdAt,
    required this.paidByName,
    required this.amongNames,
    required this.shareEach,
  });

  Map<String, dynamic> toJson() => {
        'expenseId': expenseId,
        'amount': amount,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'paidByName': paidByName,
        'amongNames': amongNames,
        'shareEach': shareEach,
      };

  factory SettlementBillSnap.fromJson(Map<String, dynamic> j) =>
      SettlementBillSnap(
        expenseId: j['expenseId'] as String? ?? '',
        amount: (j['amount'] as num).toDouble(),
        note: j['note'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        paidByName: j['paidByName'] as String? ?? '',
        amongNames: (j['amongNames'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        shareEach: (j['shareEach'] as num?)?.toDouble() ?? 0,
      );
}

/// Posted to chat when Settle → Submit is confirmed.
class SplitSettlementRecord {
  final String id;
  final DateTime createdAt;
  final double totalAmount;
  final List<SettlementBillSnap> bills;
  final List<MemberPaidTotal> paidTotals;
  final List<SettlementLine> nets;
  final List<SettlementTransfer> transfers;

  SplitSettlementRecord({
    required this.id,
    required this.createdAt,
    required this.totalAmount,
    required this.bills,
    required this.paidTotals,
    required this.nets,
    required this.transfers,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'totalAmount': totalAmount,
        'bills': bills.map((b) => b.toJson()).toList(),
        'paidTotals': paidTotals.map((p) => p.toJson()).toList(),
        'nets': nets.map((n) => n.toJson()).toList(),
        'transfers': transfers.map((t) => t.toJson()).toList(),
      };

  factory SplitSettlementRecord.fromJson(Map<String, dynamic> j) =>
      SplitSettlementRecord(
        id: j['id'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        totalAmount: (j['totalAmount'] as num).toDouble(),
        bills: (j['bills'] as List? ?? [])
            .map((e) =>
                SettlementBillSnap.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        paidTotals: (j['paidTotals'] as List? ?? [])
            .map((e) =>
                MemberPaidTotal.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        nets: (j['nets'] as List? ?? [])
            .map((e) =>
                SettlementLine.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        transfers: (j['transfers'] as List? ?? [])
            .map((e) => SettlementTransfer.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class SplitGroup {
  final String id;
  String name;
  DateTime createdAt;
  List<SplitMember> members;
  List<SplitExpense> expenses;
  List<SplitSettlementRecord> settlements;

  SplitGroup({
    required this.id,
    required this.name,
    required this.createdAt,
    List<SplitMember>? members,
    List<SplitExpense>? expenses,
    List<SplitSettlementRecord>? settlements,
  })  : members = members ?? [],
        expenses = expenses ?? [],
        settlements = settlements ?? [];

  double get totalSpent =>
      expenses.fold(0.0, (a, e) => a + e.amount);

  double get unsettledTotal => expenses
      .where((e) => !e.settled)
      .fold(0.0, (a, e) => a + e.amount);

  List<SplitExpense> get pendingExpenses =>
      expenses.where((e) => !e.settled).toList();

  /// Expenses where [memberId] paid or is in the split.
  List<SplitExpense> expensesForMember(String memberId) {
    return expenses
        .where(
          (e) =>
              e.paidById == memberId || e.splitAmongIds.contains(memberId),
        )
        .toList();
  }

  SettlementLine? settlementForMember(String memberId) {
    return settlementLines()
        .where((l) => l.memberId == memberId)
        .firstOrNull;
  }

  /// Equal-share settlement from who paid each unsettled bill.
  /// Each expense is split only among its [SplitExpense.splitAmongIds].
  /// Positive net = should receive; negative = should pay.
  List<SettlementLine> settlementLines() {
    if (members.isEmpty) return [];
    final nets = <String, double>{for (final m in members) m.id: 0};
    final names = <String, String>{for (final m in members) m.id: m.name};

    for (final e in expenses) {
      if (e.settled) continue;
      final among = e.splitAmongIds.isNotEmpty
          ? e.splitAmongIds
          : members.map((m) => m.id).toList();
      if (among.isEmpty) continue;
      final share = e.amount / among.length;
      for (final id in among) {
        nets[id] = (nets[id] ?? 0) - share;
        names.putIfAbsent(id, () {
          final i = e.splitAmongIds.indexOf(id);
          if (i >= 0 && i < e.splitAmongNames.length) {
            return e.splitAmongNames[i];
          }
          return id;
        });
      }
      nets[e.paidById] = (nets[e.paidById] ?? 0) + e.amount;
      names[e.paidById] = e.paidByName;
    }

    final lines = nets.entries
        .map(
          (e) => SettlementLine(
            memberId: e.key,
            memberName: names[e.key] ?? e.key,
            net: double.parse(e.value.toStringAsFixed(2)),
          ),
        )
        .where((l) => !l.isZero)
        .toList()
      ..sort((a, b) => b.net.compareTo(a.net));
    return lines;
  }

  List<SettlementTransfer> settlementTransfers() =>
      SettlementTransfer.fromNets(settlementLines());

  List<MemberPaidTotal> pendingPaidTotals() {
    final map = <String, MemberPaidTotal>{};
    for (final e in pendingExpenses) {
      final prev = map[e.paidById];
      map[e.paidById] = MemberPaidTotal(
        memberId: e.paidById,
        memberName: e.paidByName,
        totalPaid: (prev?.totalPaid ?? 0) + e.amount,
        billCount: (prev?.billCount ?? 0) + 1,
      );
    }
    return map.values.toList()
      ..sort((a, b) => b.totalPaid.compareTo(a.totalPaid));
  }

  SplitSettlementRecord buildSettlementRecord(String id) {
    final pending = pendingExpenses;
    final bills = pending
        .map(
          (e) => SettlementBillSnap(
            expenseId: e.id,
            amount: e.amount,
            note: e.note,
            createdAt: e.createdAt,
            paidByName: e.paidByName,
            amongNames: List<String>.from(e.splitAmongNames),
            shareEach: e.shareEach,
          ),
        )
        .toList();
    final nets = settlementLines();
    return SplitSettlementRecord(
      id: id,
      createdAt: DateTime.now(),
      totalAmount: unsettledTotal,
      bills: bills,
      paidTotals: pendingPaidTotals(),
      nets: nets,
      transfers: SettlementTransfer.fromNets(nets),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'members': members.map((m) => m.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'settlements': settlements.map((s) => s.toJson()).toList(),
      };

  factory SplitGroup.fromJson(Map<String, dynamic> j) => SplitGroup(
        id: j['id'] as String,
        name: j['name'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        members: (j['members'] as List? ?? [])
            .map((e) =>
                SplitMember.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        expenses: (j['expenses'] as List? ?? [])
            .map((e) =>
                SplitExpense.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        settlements: (j['settlements'] as List? ?? [])
            .map((e) => SplitSettlementRecord.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  static String encodeList(List<SplitGroup> groups) =>
      jsonEncode(groups.map((g) => g.toJson()).toList());

  static List<SplitGroup> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => SplitGroup.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
