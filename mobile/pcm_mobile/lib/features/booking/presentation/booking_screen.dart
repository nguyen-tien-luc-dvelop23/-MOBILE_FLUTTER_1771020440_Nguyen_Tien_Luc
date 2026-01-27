import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/session/session_provider.dart';
import '../../../services/api_service.dart';
import 'my_bookings_screen.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _courts = [];
  int? _selectedCourtId;
  bool _loading = false;
  List<dynamic> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    final courts = await ApiService.getCourts();
    final day = DateTime.now();
    final bookings = await ApiService.getBookingsCalendar(
      from: DateTime(day.year, day.month, day.day, 0, 0),
      to: DateTime(day.year, day.month, day.day, 23, 59),
    );
    if (!mounted) return;
    setState(() {
      _courts = courts;
      _selectedCourtId = courts.isNotEmpty ? courts.first['id'] as int : null;
      _selectedDay = day;
      _bookings = bookings;
      _loading = false;
    });
  }

  Future<void> _refreshBookings(DateTime day) async {
    final data = await ApiService.getBookingsCalendar(
      from: DateTime(day.year, day.month, day.day, 0, 0),
      to: DateTime(day.year, day.month, day.day, 23, 59),
    );
    if (!mounted) return;
    setState(() {
      _bookings = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _refreshBookings(selectedDay);
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chọn sân & slot',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (_loading)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MyBookingsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text('Lịch sử'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedCourtId,
                  decoration: const InputDecoration(labelText: 'Sân'),
                  items: _courts
                      .map(
                        (c) => DropdownMenuItem<int>(
                          value: c['id'] as int,
                          child: Text(
                            c['name']?.toString() ?? 'Sân ${c['id']}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCourtId = v),
                ),
                const SizedBox(height: 12),
                _buildSlots(context),
                const SizedBox(height: 10),
                Text(
                  'Màu: Đỏ=Đã đặt, Xanh=Slot của tôi, Xám=Trống.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlots(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final day = _selectedDay ?? DateTime.now();
    final slots = _generateSlots(day);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((s) {
        final state = s.state;
        Color bg;
        Color fg;
        switch (state) {
          case SlotState.booked:
            bg = scheme.errorContainer;
            fg = scheme.onErrorContainer;
          case SlotState.mine:
            bg = scheme.primaryContainer;
            fg = scheme.onPrimaryContainer;
          case SlotState.empty:
            bg = scheme.surface;
            fg = scheme.onSurface;
        }
        return InkWell(
          onTap: state == SlotState.empty
              ? () => _bookSlot(s.start, s.end)
              : null,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(
              '${_fmt(s.start)} - ${_fmt(s.end)}',
              style: TextStyle(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  List<_Slot> _generateSlots(DateTime day) {
    // fixed hourly slots 06:00-22:00
    final startHour = 6;
    final endHour = 22;
    final selectedCourt = _selectedCourtId;
    if (selectedCourt == null) return [];

    return List.generate(endHour - startHour, (i) {
      final start = DateTime(day.year, day.month, day.day, startHour + i, 0);
      final end = start.add(const Duration(hours: 1));
      final overlap = _bookings.where((b) {
        if (b['courtId'] != selectedCourt) return false;
        final st = DateTime.parse(b['startTime']);
        final et = DateTime.parse(b['endTime']);
        return st.isBefore(end) && et.isAfter(start);
      }).toList();

      SlotState state = SlotState.empty;
      if (overlap.isNotEmpty) {
        state = SlotState.booked;
      }

      return _Slot(start: start, end: end, state: state);
    });
  }

  Future<void> _bookSlot(DateTime start, DateTime end) async {
    if (_selectedCourtId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đặt sân'),
        content: Text(
          'Bạn có chắc muốn đặt sân từ ${_fmt(start)} đến ${_fmt(end)} không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await ApiService.createBooking(
      courtId: _selectedCourtId!,
      startTime: start,
      endTime: end,
    );
    if (!mounted) return;
    if (ok) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thành công'),
          content: const Text(
            'Đặt sân thành công! Bạn có thể xem trong Lịch sử đặt sân.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      await _refreshBookings(start);
      // Refresh session để update số dư ví
      ref.read(sessionProvider.notifier).refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt sân thất bại. Kiểm tra số dư hoặc slot.'),
        ),
      );
    }
  }
}

enum SlotState { booked, mine, empty }

class _Slot {
  _Slot({required this.start, required this.end, required this.state});
  final DateTime start;
  final DateTime end;
  final SlotState state;
}
