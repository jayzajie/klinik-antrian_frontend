import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  List<dynamic> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final result = await AdminService.getAuditLogs();
      setState(() {
        // Handle paginated response
        if (result['data'] is List) {
          _logs = result['data'];
        } else {
          _logs = [];
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

  String _formatAction(String action) {
    return action.replaceAll('_', ' ').toUpperCase();
  }

  Color _getActionColor(String action) {
    if (action.contains('create')) return Colors.green;
    if (action.contains('update')) return Colors.blue;
    if (action.contains('delete') || action.contains('cancel')) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('No audit logs'))
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final user = log['user'];
                    final createdAt = DateTime.parse(log['created_at']);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getActionColor(log['action']),
                          child: const Icon(Icons.history, color: Colors.white),
                        ),
                        title: Text(_formatAction(log['action'])),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('By: ${user?['name'] ?? 'System'}'),
                            Text('Time: ${DateFormat('dd MMM yyyy HH:mm').format(createdAt)}'),
                            if (log['ip_address'] != null)
                              Text('IP: ${log['ip_address']}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(_formatAction(log['action'])),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('User: ${user?['name'] ?? 'System'}'),
                                    Text('Time: ${DateFormat('dd MMM yyyy HH:mm:ss').format(createdAt)}'),
                                    if (log['ip_address'] != null)
                                      Text('IP: ${log['ip_address']}'),
                                    if (log['old_values'] != null) ...[
                                      const SizedBox(height: 16),
                                      const Text('Old Values:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(log['old_values'].toString()),
                                    ],
                                    if (log['new_values'] != null) ...[
                                      const SizedBox(height: 16),
                                      const Text('New Values:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(log['new_values'].toString()),
                                    ],
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
