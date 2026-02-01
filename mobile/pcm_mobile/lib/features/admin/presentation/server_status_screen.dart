import 'package:flutter/material.dart';
import '../../../../services/api_service.dart';

class ServerStatusScreen extends StatefulWidget {
  const ServerStatusScreen({super.key});

  @override
  State<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends State<ServerStatusScreen> {
  Map<String, dynamic>? _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    final status = await ApiService.checkServerStatus();
    setState(() {
      _status = status;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Server Diagnostics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   ElevatedButton.icon(
                    onPressed: _checkStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Status'),
                  ),
                  const SizedBox(height: 16),
                  if (_status != null) ..._buildStatusItems(_status!),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildStatusItems(Map<String, dynamic> data) {
    return data.entries.map((e) {
      Color? cardColor;
      if (e.key == 'AdminUserIsAdmin') {
        cardColor = e.value == true ? Colors.green.shade100 : Colors.red.shade100;
      }
      
      return Card(
        color: cardColor,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(e.value.toString()),
        ),
      );
    }).toList();
  }
}
