import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'booking_screen.dart';

class CourtListScreen extends StatefulWidget {
  const CourtListScreen({super.key});

  @override
  State<CourtListScreen> createState() => _CourtListScreenState();
}

class _CourtListScreenState extends State<CourtListScreen> {
  List courts = [];

  @override
  void initState() {
    super.initState();
    loadCourts();
  }

  void loadCourts() async {
    final data = await ApiService.getCourts();
    setState(() => courts = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courts')),
      body: ListView.builder(
        itemCount: courts.length,
        itemBuilder: (context, i) {
          final c = courts[i];

          return ListTile(
            title: Text(c['name']),
            subtitle: Text('Price: ${c['pricePerHour']}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingScreen(courtId: c['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
