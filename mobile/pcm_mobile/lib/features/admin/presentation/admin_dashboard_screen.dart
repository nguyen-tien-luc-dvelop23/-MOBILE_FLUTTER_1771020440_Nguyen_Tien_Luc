import 'package:flutter/material.dart';

import '../../../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _loading = false;
  List<dynamic> _bookings = [];
  List<dynamic> _members = [];
  List<dynamic> _transactions = [];
  List<dynamic> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final b = await ApiService.adminAllBookings();
    final m = await ApiService.getMembers();
    final t = await ApiService.adminAllTransactions();
    final tr = await ApiService.getTournaments();
    if (!mounted) return;
    setState(() {
      _bookings = b;
      _members = m;
      _transactions = t;
      _tournaments = tr;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin dashboard'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Bookings'),
            Tab(text: 'Members'),
            Tab(text: 'Transactions'),
            Tab(text: 'Tournaments'),
          ],
        ),
      ),
      floatingActionButton: _tab.index == 3
          ? FloatingActionButton(
              onPressed: _showAddTournamentDialog,
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tab,
                children: [
                  _buildBookings(),
                  _buildMembers(),
                  _buildTransactions(),
                  _buildTournaments(),
                ],
              ),
      ),
    );
  }

  void _showAddTournamentDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final feeCtrl = TextEditingController();
    final playersCtrl = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    String type = 'SingleElimination';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Thêm giải đấu mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên giải đấu'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                ),
                TextField(
                  controller: feeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phí tham gia (₫)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: playersCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng người tối đa',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Loại giải'),
                  items: const [
                    DropdownMenuItem(
                      value: 'SingleElimination',
                      child: Text('Loại trực tiếp'),
                    ),
                    DropdownMenuItem(
                      value: 'RoundRobin',
                      child: Text('Vòng tròn'),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    startDate == null
                        ? 'Chọn ngày bắt đầu'
                        : 'Bắt đầu: ${startDate!.day}/${startDate!.month}/${startDate!.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) setDialogState(() => startDate = d);
                  },
                ),
                ListTile(
                  title: Text(
                    endDate == null
                        ? 'Chọn ngày kết thúc'
                        : 'Kết thúc: ${endDate!.day}/${endDate!.month}/${endDate!.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate:
                          startDate ??
                          DateTime.now().add(const Duration(days: 2)),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) setDialogState(() => endDate = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty ||
                    feeCtrl.text.isEmpty ||
                    playersCtrl.text.isEmpty)
                  return;
                final ok = await ApiService.createTournament(
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  startDate: startDate,
                  endDate: endDate,
                  entryFee: double.tryParse(feeCtrl.text) ?? 0,
                  maxPlayers: int.tryParse(playersCtrl.text) ?? 0,
                  type: type,
                );
                if (ok) {
                  Navigator.pop(ctx);
                  _loadAll();
                }
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournaments() {
    if (_tournaments.isEmpty)
      return const Center(child: Text('Không có giải đấu'));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _tournaments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final t = _tournaments[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.emoji_events),
            title: Text(t['name'] ?? ''),
            subtitle: Text(
              'Status: ${t['status']} • Fee: ${t['entryFee']}₫\nMax: ${t['maxPlayers']} người',
            ),
            isThreeLine: true,
            trailing: t['status'] == 'Open'
                ? IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                    tooltip: 'Bắt đầu giải (Generate Bracket)',
                    onPressed: () async {
                      // Logic gọi API generate-schedule ở đây nếu cần
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildBookings() {
    if (_bookings.isEmpty) return const Center(child: Text('Không có booking'));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final b = _bookings[i];
        return Card(
          child: ListTile(
            title: Text('Booking #${b['id']} - Sân ${b['courtId']}'),
            subtitle: Text(
              '${b['member']?['fullName'] ?? ''}\n${b['startTime']} - ${b['endTime']}\nStatus: ${b['status']}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildMembers() {
    if (_members.isEmpty) return const Center(child: Text('Không có member'));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final m = _members[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(m['fullName'] ?? ''),
            subtitle: Text('${m['email']} • Tier: ${m['tier']}'),
            trailing: Text('Wallet: ${(m['walletBalance'] ?? 0)}'),
          ),
        );
      },
    );
  }

  Widget _buildTransactions() {
    if (_transactions.isEmpty)
      return const Center(child: Text('Không có giao dịch'));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final t = _transactions[i];
        final amount = (t['amount'] ?? 0).toDouble();
        final color = amount >= 0 ? Colors.green : Colors.red;
        return Card(
          child: ListTile(
            title: Text(t['description'] ?? t['type'] ?? ''),
            subtitle: Text(
              '${t['member']?['fullName'] ?? ''} • ${t['createdDate'] ?? ''}',
            ),
            trailing: Text(
              amount.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
        );
      },
    );
  }
}
