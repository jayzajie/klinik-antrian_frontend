import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/department.dart';
import '../../services/api_service.dart';

class TakeQueueScreen extends StatefulWidget {
  final Department department;

  const TakeQueueScreen({super.key, required this.department});

  @override
  State<TakeQueueScreen> createState() => _TakeQueueScreenState();
}

class _TakeQueueScreenState extends State<TakeQueueScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _takeQueue() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post('/queues/take', {
        'department_id': widget.department.id,
        'queue_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      });

      if (!mounted) return;

      if (response['success']) {
        final queueNumber = response['data']['queue_number'];
        final estimatedWait = response['data']['estimated_wait_minutes'];
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nomor Antrian Anda',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '$queueNumber',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                if (estimatedWait != null && estimatedWait > 0) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Estimasi tunggu: ${_formatWaitTime(estimatedWait)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.department.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                  .format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _takeQueue,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Ambil Antrian'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatWaitTime(int minutes) {
    if (minutes < 60) {
      return '~$minutes menit';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '~$hours jam ${mins > 0 ? "$mins menit" : ""}';
  }
}
