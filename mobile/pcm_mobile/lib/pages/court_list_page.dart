import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'booking_page.dart';


class CourtListPage extends StatefulWidget {
  const CourtListPage({super.key});

  @override
  State<CourtListPage> createState() => _CourtListPageState();
}

class _CourtListPageState extends State<CourtListPage> {
  List courts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCourts();
  }

  Future<void> loadCourts() async {
    final data = await ApiService.getCourts();
    setState(() {
      courts = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách sân')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: courts.length,
              itemBuilder: (context, index) {
                final court = courts[index];
                return Card(
                  child: ListTile(
                    title: Text(court['name']),
                    subtitle: Text(
                        'Giá: ${court['pricePerHour']} VND / giờ'),
                    trailing: ElevatedButton(
                      child: const Text('Đặt'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingPage(courtId: court['id']),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
