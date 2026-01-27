import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WalletHeroCard(balance: ref.watch(sessionProvider).valueOrNull?.walletBalance ?? 0),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Biểu đồ Rank (demo)', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          spots: const [
                            FlSpot(0, 2.1),
                            FlSpot(1, 2.2),
                            FlSpot(2, 2.15),
                            FlSpot(3, 2.35),
                            FlSpot(4, 2.4),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lịch thi đấu sắp tới', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ...List.generate(
                  3,
                  (i) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.sports_tennis),
                    title: Text('Trận #${i + 1} • Sân 1'),
                    subtitle: const Text('20:00 • 28/01/2026'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletHeroCard extends StatelessWidget {
  const _WalletHeroCard({required this.balance});
  final double balance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [scheme.primary, scheme.tertiary]),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: scheme.onPrimary.withValues(alpha: 0.18),
            child: Icon(Icons.account_balance_wallet, color: scheme.onPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số dư ví',
                  style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.9)),
                ),
                Text(
                  '${balance.toStringAsFixed(0)}₫',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: scheme.onPrimary.withValues(alpha: 0.18),
              foregroundColor: scheme.onPrimary,
            ),
            child: const Text('Nạp'),
          ),
        ],
      ),
    );
  }
}


