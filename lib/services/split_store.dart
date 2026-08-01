import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/split_models.dart';

class SplitStore extends ChangeNotifier {
  static const _key = 'tripo_split_groups_v2';
  static final SplitStore instance = SplitStore._();
  SplitStore._();

  List<SplitGroup> _groups = [];
  bool _loaded = false;

  List<SplitGroup> get groups => List.unmodifiable(_groups);
  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    var raw = prefs.getString(_key);
    // One-time migrate from v1 if needed.
    if (raw == null || raw.isEmpty) {
      raw = prefs.getString('tripo_split_groups_v1');
    }
    _groups = SplitGroup.decodeList(raw);
    var needsSave = false;
    for (final g in _groups) {
      if (SplitMemberColors.ensureGroup(g)) needsSave = true;
    }
    _loaded = true;
    if (needsSave) {
      await _persist();
    } else {
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, SplitGroup.encodeList(_groups));
    notifyListeners();
  }

  SplitGroup? byId(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  String _uid() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<SplitGroup> createGroup({
    required String name,
    required String myName,
    required String myPhone,
  }) async {
    final g = SplitGroup(
      id: _uid(),
      name: name.trim(),
      createdAt: DateTime.now(),
      members: [
        SplitMember(
          id: 'you',
          name: myName.trim(),
          phone: myPhone.trim(),
          colorValue: SplitMemberColors.palette.first,
        ),
      ],
    );
    _groups.insert(0, g);
    await _persist();
    return g;
  }

  Future<void> renameGroup(String id, String name) async {
    final g = byId(id);
    if (g == null) return;
    g.name = name.trim();
    await _persist();
  }

  Future<void> deleteGroup(String id) async {
    _groups.removeWhere((g) => g.id == id);
    await _persist();
  }

  Future<void> addMember({
    required String groupId,
    required String name,
    required String phone,
  }) async {
    final g = byId(groupId);
    if (g == null || name.trim().isEmpty) return;
    g.members.add(
      SplitMember(
        id: _uid(),
        name: name.trim(),
        phone: phone.trim(),
        colorValue: SplitMemberColors.nextFor(g.members),
      ),
    );
    await _persist();
  }

  Future<void> updateMember({
    required String groupId,
    required String memberId,
    required String name,
    required String phone,
  }) async {
    final g = byId(groupId);
    if (g == null) return;
    final m = g.members.where((e) => e.id == memberId).firstOrNull;
    if (m == null || name.trim().isEmpty) return;
    m.name = name.trim();
    m.phone = phone.trim();
    await _persist();
  }

  Future<void> removeMember(String groupId, String memberId) async {
    final g = byId(groupId);
    if (g == null || memberId == 'you') return;
    g.members.removeWhere((m) => m.id == memberId);
    await _persist();
  }

  /// Record: [paidBy] paid [amount], split equally among [splitAmong].
  Future<SplitExpense?> addExpense({
    required String groupId,
    required double amount,
    required String note,
    DateTime? remindAt,
    required SplitMember paidBy,
    required List<SplitMember> splitAmong,
  }) async {
    final g = byId(groupId);
    if (g == null || amount <= 0 || splitAmong.isEmpty) return null;

    final expense = SplitExpense(
      id: _uid(),
      amount: amount,
      note: note.trim(),
      createdAt: DateTime.now(),
      remindAt: remindAt,
      paidById: paidBy.id,
      paidByName: paidBy.name,
      paidForId: paidBy.id,
      paidForName: paidBy.name,
      splitAmongIds: splitAmong.map((m) => m.id).toList(),
      splitAmongNames: splitAmong.map((m) => m.name).toList(),
    );
    g.expenses.add(expense);
    await _persist();
    return expense;
  }

  Future<void> updateExpense({
    required String groupId,
    required String expenseId,
    double? amount,
    String? note,
    DateTime? remindAt,
    bool clearRemind = false,
  }) async {
    final g = byId(groupId);
    if (g == null) return;
    final e = g.expenses.where((x) => x.id == expenseId).firstOrNull;
    if (e == null) return;
    if (amount != null && amount > 0) e.amount = amount;
    if (note != null) e.note = note.trim();
    if (clearRemind) {
      e.remindAt = null;
    } else if (remindAt != null) {
      e.remindAt = remindAt;
    }
    await _persist();
  }

  Future<void> toggleExpenseSettled({
    required String groupId,
    required String expenseId,
  }) async {
    final g = byId(groupId);
    if (g == null) return;
    final e = g.expenses.where((x) => x.id == expenseId).firstOrNull;
    if (e == null) return;
    e.settled = !e.settled;
    await _persist();
  }

  Future<SplitSettlementRecord?> settleAll(String groupId) async {
    final g = byId(groupId);
    if (g == null) return null;
    final pending = g.pendingExpenses;
    if (pending.isEmpty) return null;

    final record = g.buildSettlementRecord(_uid());
    for (final e in g.expenses) {
      e.settled = true;
    }
    g.settlements.add(record);
    await _persist();
    return record;
  }

  Future<void> toggleExpanded({
    required String groupId,
    required String expenseId,
  }) async {
    final g = byId(groupId);
    if (g == null) return;
    final e = g.expenses.where((x) => x.id == expenseId).firstOrNull;
    if (e == null) return;
    e.expanded = !e.expanded;
    await _persist();
  }

  Future<void> deleteExpense(String groupId, String expenseId) async {
    final g = byId(groupId);
    if (g == null) return;
    g.expenses.removeWhere((e) => e.id == expenseId);
    await _persist();
  }
}
