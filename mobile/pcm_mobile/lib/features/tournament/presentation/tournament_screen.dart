import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../services/api_service.dart';
import '../../../core/session/session_provider.dart';

class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key});

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen> {
  bool _loading = false;
  bool _joining = false;
  List<dynamic> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final data = await ApiService.getTournaments();
    if (!mounted) return;
    setState(() {
      _tournaments = data;
      _loading = false;
    });
  }

  Future<void> _join(int id, String name, double fee) async {
    if (_joining) return;

    final groupNameCtrl = TextEditingController();
    final teamSizeCtrl = TextEditingController(text: '1');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tham gia giải đấu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Phí tham gia: ${NumberFormat('#,###').format(fee)}₫.\nBạn có chắc muốn tham gia "$name"?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: groupNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên nhóm / Tên VĐV',
                hintText: 'VD: CLB Pickleball A',
              ),
            ),
            TextField(
              controller: teamSizeCtrl,
              decoration: const InputDecoration(labelText: 'Số lượng người'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận & Trừ ví'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _joining = true);
    try {
      final ok = await ApiService.joinTournament(
        tournamentId: id,
        groupName: groupNameCtrl.text,
        teamSize: int.tryParse(teamSizeCtrl.text) ?? 1,
      );
      if (!mounted) return;
      if (ok) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thành công'),
            content: const Text('Đã tham gia giải đấu!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        // Refresh data và session
        await Future.wait([
          _loadData(),
          ref.read(sessionProvider.notifier).refresh(),
        ]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tham gia thất bại. Kiểm tra số dư hoặc giải đã đầy.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _tournaments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: _tournaments.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 100),
                Center(child: Text('Hiện chưa có giải đấu nào.')),
                Center(
                  child: Text(
                    'Vuốt xuống để tải lại',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tournaments.length,
              itemBuilder: (context, index) {
                final t = _tournaments[index];
                final name = t['name'] ?? 'Giải ???';
                final fee = (t['entryFee'] ?? 0).toDouble();
                final status = t['status'] ?? 'Open'; // Open, Ongoing, Finished
                final id = t['id'];
                final maxPlayers = t['maxPlayers'] ?? 0;
                final participants = t['participants'] as List<dynamic>? ?? [];
                final currentCount = participants.length;

                // Kiểm tra xem mình đã tham gia chưa
                final session = ref.watch(sessionProvider).valueOrNull;
                final isJoined = participants.any(
                  (p) => p['userId'] == session?.memberId,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events_outlined),
                    title: Text(name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fee: ${NumberFormat('#,###').format(fee)}₫ • ${status == 'Open' ? 'Đang mở' : status}',
                        ),
                        Text(
                          'Người tham gia: $currentCount/$maxPlayers',
                          style: TextStyle(
                            color: currentCount >= maxPlayers
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    trailing: status == 'Open'
                        ? FilledButton.tonal(
                            onPressed:
                                (currentCount < maxPlayers &&
                                    !isJoined &&
                                    !_joining)
                                ? () => _join(id, name, fee)
                                : null,
                            child: Text(
                              isJoined
                                  ? 'Đã tham gia'
                                  : (currentCount < maxPlayers
                                        ? 'Tham gia'
                                        : 'Đã đầy'),
                            ),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: status != 'Open'
                        ? () {
                            // TODO: Navigate to bracket detail
                          }
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
