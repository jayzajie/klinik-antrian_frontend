import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class QueueDisplayScreen extends StatefulWidget {
  const QueueDisplayScreen({super.key});

  @override
  State<QueueDisplayScreen> createState() => _QueueDisplayScreenState();
}

class _QueueDisplayScreenState extends State<QueueDisplayScreen> {
  List<dynamic> _departments = [];
  Timer? _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadDisplay();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
      if (DateTime.now().second % 5 == 0) {
        _loadDisplay();
      }
    });
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDisplay() async {
    try {
      final response = await ApiService.get('/queue-display');
      if (response['success'] && mounted) {
        setState(() {
          _departments = response['data']['departments'];
        });
      }
    } catch (e) {
      // Silent fail untuk display
    }
  }

  IconData _getDepartmentIcon(String name) {
    if (name.toLowerCase().contains('umum')) return Icons.local_hospital;
    if (name.toLowerCase().contains('gigi')) return Icons.medical_services;
    if (name.toLowerCase().contains('anak')) return Icons.child_care;
    if (name.toLowerCase().contains('mata')) return Icons.remove_red_eye;
    return Icons.local_hospital;
  }

  Color _getDepartmentColor(String name) {
    if (name.toLowerCase().contains('umum')) return const Color(0xFF4DB6AC);
    if (name.toLowerCase().contains('gigi')) return const Color(0xFF4DB6AC);
    if (name.toLowerCase().contains('anak')) return const Color(0xFF4DB6AC);
    if (name.toLowerCase().contains('mata')) return const Color(0xFF4DB6AC);
    return const Color(0xFF4DB6AC);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan gradient
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF2E5F8A),
                    const Color(0xFF4A90A4),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon dan text di kiri
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ANTRIAN',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.local_hospital,
                                    color: Color(0xFF2E5F8A),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'KLINIK',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('EEEE, dd MMMM', 'id_ID')
                                          .format(DateTime.now()),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Jam di kanan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _currentTime,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          Text(
                            DateFormat('hh:mm a').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Status badge
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Status: Buka',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E5F8A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Grid cards
            Expanded(
              child: _departments.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _departments.length,
                      itemBuilder: (context, index) {
                        final dept = _departments[index];
                        return _buildDepartmentCard(dept);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> dept) {
    final department = dept['department'];
    final currentQueue = dept['current_queue'];
    final waitingCount = dept['waiting_count'];
    final nextQueues = dept['next_queues'] as List;

    final icon = _getDepartmentIcon(department['name']);
    final color = _getDepartmentColor(department['name']);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                // Nama poli
                Text(
                  department['name'],
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Nomor antrian atau status
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentQueue != null) ...[
                          Text(
                            '${currentQueue['queue_number']}',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Nomor Antrian Anda',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ] else if (waitingCount > 0 && nextQueues.isNotEmpty) ...[
                          Text(
                            '${nextQueues[0]}',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                              height: 1,
                            ),
                          ),
                          if (waitingCount > 1) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Menunggu ${waitingCount - 1} orang',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ] else ...[
                          const Text(
                            'Tidak ada antrian',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Info menunggu
                Text(
                  'Menunggu: $waitingCount orang',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Icon hijau di pojok kanan bawah - hanya jika ada antrian
          if (currentQueue != null || waitingCount > 0)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
