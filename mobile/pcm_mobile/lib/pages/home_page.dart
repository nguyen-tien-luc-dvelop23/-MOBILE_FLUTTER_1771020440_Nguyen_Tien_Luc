import 'package:flutter/material.dart';
import 'court_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PCM Home')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Xem danh sách sân'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CourtListPage()),
            );
          },
        ),
      ),
    );
  }
}
