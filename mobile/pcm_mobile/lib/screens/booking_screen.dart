import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final int courtId;

  const BookingScreen({super.key, required this.courtId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? startTime;
  DateTime? endTime;
  bool loading = false;

  Future<void> pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        startTime = selected;
      } else {
        endTime = selected;
      }
    });
  }

  void submitBooking() async {
    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select time')),
      );
      return;
    }

    setState(() => loading = true);
    final success = await ApiService.createBooking(
      courtId: widget.courtId,
      startTime: startTime!,
      endTime: endTime!,
    );
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Booking successful' : 'Booking failed'),
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Court')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => pickDateTime(true),
              child: Text(
                startTime == null
                    ? 'Select start time'
                    : startTime.toString(),
              ),
            ),
            ElevatedButton(
              onPressed: () => pickDateTime(false),
              child: Text(
                endTime == null ? 'Select end time' : endTime.toString(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submitBooking,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
