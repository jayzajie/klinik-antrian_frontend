import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class QueueSettingsScreen extends StatefulWidget {
  const QueueSettingsScreen({super.key});

  @override
  State<QueueSettingsScreen> createState() => _QueueSettingsScreenState();
}

class _QueueSettingsScreenState extends State<QueueSettingsScreen> {
  List<dynamic> _settings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final result = await AdminService.getQueueSettings();
      setState(() {
        // Handle response - data is already an array
        if (result['data'] is List) {
          _settings = result['data'];
        } else {
          _settings = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _editSetting(Map<String, dynamic> setting) {
    final openingController = TextEditingController(text: setting['opening_time']);
    final closingController = TextEditingController(text: setting['closing_time']);
    final maxQueueController = TextEditingController(text: setting['max_queue_per_day'].toString());
    final avgServiceController = TextEditingController(text: setting['average_service_minutes'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${setting['department']['name']} Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: openingController,
                decoration: const InputDecoration(labelText: 'Opening Time (HH:mm)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: closingController,
                decoration: const InputDecoration(labelText: 'Closing Time (HH:mm)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: maxQueueController,
                decoration: const InputDecoration(labelText: 'Max Queue Per Day'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: avgServiceController,
                decoration: const InputDecoration(labelText: 'Avg Service Minutes'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await AdminService.updateQueueSetting(setting['id'], {
                  'opening_time': openingController.text,
                  'closing_time': closingController.text,
                  'max_queue_per_day': int.parse(maxQueueController.text),
                  'average_service_minutes': int.parse(avgServiceController.text),
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings updated')),
                  );
                  _loadSettings();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings.isEmpty
              ? const Center(child: Text('No settings found'))
              : ListView.builder(
                  itemCount: _settings.length,
                  itemBuilder: (context, index) {
                    final setting = _settings[index];
                    return Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              setting['department']['name'],
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Opening Time', setting['opening_time']),
                            _buildInfoRow('Closing Time', setting['closing_time']),
                            _buildInfoRow('Max Queue/Day', setting['max_queue_per_day'].toString()),
                            _buildInfoRow('Avg Service', '${setting['average_service_minutes']} min'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _editSetting(setting),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Settings'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
