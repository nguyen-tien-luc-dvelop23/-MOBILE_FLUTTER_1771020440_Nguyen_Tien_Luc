import 'package:flutter/material.dart';

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/session/session_provider.dart';
import '../../../services/api_service.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _loading = false;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final txs = await ApiService.walletTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = txs;
      _loading = false;
    });
    await ref.read(sessionProvider.notifier).refresh();
  }

  Future<void> _showDepositSheet() async {
    final amountCtrl = TextEditingController();
    final scheme = Theme.of(context).colorScheme;
    final random = Random();
    final content = 'PCM${DateTime.now().millisecondsSinceEpoch}${random.nextInt(99).toString().padLeft(2, '0')}';

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Nạp tiền (QR)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền (VNĐ)',
                  prefixIcon: Icon(Icons.money_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Text('Nội dung: $content', style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: QrImageView(
                    data: 'VietQR|account=luc|content=$content',
                    size: 220,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sau khi bạn chuyển khoản theo QR, bấm xác nhận để hệ thống ghi nhận vào ví và lưu lịch sử (MySQL).',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () async {
                  final value = double.tryParse(amountCtrl.text);
                  if (value == null || value <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Số tiền không hợp lệ')),
                    );
                    return;
                  }
                  final ok = await ApiService.deposit(
                    amount: value,
                    description: 'QR:$content',
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã ghi nhận nạp tiền và lưu vào MySQL')),
                    );
                    await _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không ghi nhận được yêu cầu nạp tiền. Hãy đăng nhập lại.')),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Xác nhận đã chuyển khoản'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final balance = ref.watch(sessionProvider).valueOrNull?.walletBalance ?? 0;
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(colors: [scheme.primary, scheme.tertiary]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Số dư ví', style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.9))),
                Text(
                  '${balance.toStringAsFixed(0)}₫',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: _showDepositSheet,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.onPrimary.withValues(alpha: 0.18),
                    foregroundColor: scheme.onPrimary,
                  ),
                  child: const Text('Nạp tiền'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lịch sử giao dịch', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_transactions.isEmpty)
                    const Text('Chưa có giao dịch.'),
                  ..._transactions.map(
                    (t) => _TxTile(
                      title: t['description'] ?? t['type'] ?? '',
                      amount: (t['amount'] ?? 0).toString(),
                      color: (t['amount'] ?? 0) >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.title, required this.amount, required this.color});
  final String title;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(Icons.swap_horiz, color: color),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: const Text('27/01/2026 • Completed'),
      trailing: Text(
        amount,
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}


