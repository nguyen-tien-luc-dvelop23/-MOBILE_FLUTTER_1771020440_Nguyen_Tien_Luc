import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookingPage extends StatefulWidget {
  final int courtId;
  const BookingPage({super.key, required this.courtId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? startTime;
  DateTime? endTime;
  bool loading = false;

  Future<void> book() async {
    if (startTime == null || endTime == null) return;

    setState(() => loading = true);

    final success = await ApiService.createBooking(
      courtId: widget.courtId,
      startTime: startTime!,
      endTime: endTime!,
    );

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '🎉 Đặt sân thành công' : '❌ Đặt sân thất bại',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.pop(context);
  }

  String formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.day}/${time.month}/${time.year} - ${time.hour}:00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lịch')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    startTime == null
                        ? 'Chọn giờ bắt đầu'
                        : 'Bắt đầu: ${formatTime(startTime)}',
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setState(() {
                        startTime =
                            date.add(const Duration(hours: 8));
                        endTime = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.timelapse),
                  label: Text(
                    endTime == null
                        ? 'Chọn giờ kết thúc'
                        : 'Kết thúc: ${formatTime(endTime)}',
                  ),
                  onPressed: startTime == null
                      ? null
                      : () {
                          setState(() {
                            endTime = startTime!
                                .add(const Duration(hours: 2));
                          });
                        },
                ),
                const SizedBox(height: 24),
                loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (startTime != null &&
                                  endTime != null)
                              ? book
                              : null,
                          child: const Text('Xác nhận đặt sân'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
