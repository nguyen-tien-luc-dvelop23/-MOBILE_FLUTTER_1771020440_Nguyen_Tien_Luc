import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.campaign_outlined),
                  title: Text('Nạp tiền thành công'),
                  subtitle: Text('Số dư ví đã được cập nhật.'),
                  trailing: _UnreadDot(),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.calendar_month_outlined),
                  title: Text('Booking đã xác nhận'),
                  subtitle: Text('Sân 1 • 20:00 - 21:00'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đánh dấu tất cả đã đọc.')),
              );
            },
            child: const Text('Đánh dấu tất cả đã đọc'),
          ),
        ],
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: scheme.error,
        shape: BoxShape.circle,
      ),
    );
  }
}


