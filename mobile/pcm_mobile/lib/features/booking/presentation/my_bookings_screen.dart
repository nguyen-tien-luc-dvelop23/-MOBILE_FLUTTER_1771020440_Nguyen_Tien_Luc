import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _loading = false;
  List<dynamic> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await ApiService.getMyBookings();
    if (!mounted) return;
    setState(() {
      _bookings = data;
      _loading = false;
    });
  }

  Future<void> _cancelBooking(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đặt sân'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy đặt sân này? \n'
          'Chính sách hoàn tiền: \n'
          '- Trước 24h: Hoàn 100% \n'
          '- Trước 12h: Hoàn 50% \n'
          '- Còn lại: Không hoàn tiền.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Đóng'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hủy sân'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await ApiService.cancelBooking(id);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hủy sân thành công! Tiền đã được hoàn (nếu có).'),
        ),
      );
      _loadData(); // Reload list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hủy sân thất bại. Có thể đã quá hạn hủy.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đặt sân')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? const Center(child: Text('Bạn chưa có lịch đặt sân nào.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final item = _bookings[index];
                final courtName = item['court']?['name'] ?? 'Sân ???';
                final start = DateTime.parse(item['startTime']);
                final end = DateTime.parse(item['endTime']);
                final status = item['status']; // Confirmed, Cancelled
                final price = item['totalPrice'];
                final created = DateTime.parse(item['createdDate']);

                final isCancelled = status == 'Cancelled';
                final canCancel = !isCancelled && start.isAfter(DateTime.now());

                Color statusColor = Colors.green;
                if (isCancelled)
                  statusColor = Colors.red;
                else if (status == 'Pending')
                  statusColor = Colors.orange;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              courtName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}',
                        ),
                        Text('Giá: ${NumberFormat('#,###').format(price)}₫'),
                        Text(
                          'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(created)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        if (canCancel) ...[
                          const Divider(),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _cancelBooking(item['id']),
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Hủy đặt sân'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
