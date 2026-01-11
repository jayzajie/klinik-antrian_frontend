import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class QueueManagementScreen extends StatefulWidget {
  const QueueManagementScreen({super.key});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  List<dynamic> _departments = [];
  int? _selectedDepartmentId;
  List<dynamic> _queues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final response = await ApiService.get('/departments');
      if (response['success'] && mounted) {
        setState(() {
          _departments = response['data'];
          _isLoading = false;
          if (_departments.isNotEmpty) {
            _selectedDepartmentId = _departments[0]['id'];
            _loadQueues();
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadQueues() async {
    if (_selectedDepartmentId == null) return;

    try {
      final response = await ApiService.get(
        '/admin/queues?department_id=$_selectedDepartmentId&status=waiting,called',
      );
      if (response['success'] && mounted) {
        setState(() {
          _queues = response['data'];
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _callQueue(int queueId) async {
    try {
      final response = await ApiService.post('/admin/queues/$queueId/call', {});
      if (response['success']) {
        _loadQueues();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Antrian berhasil dipanggil')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _completeQueue(int queueId) async {
    try {
      final response =
          await ApiService.post('/admin/queues/$queueId/done', {});
      if (response['success']) {
        _loadQueues();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Antrian berhasil diselesaikan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _skipQueue(int queueId) async {
    try {
      final response = await ApiService.post('/admin/queues/$queueId/skip', {});
      if (response['success']) {
        _loadQueues();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Antrian berhasil dilewati')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _cancelQueue(int queueId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _CancelDialog(),
    );

    if (reason == null || reason.isEmpty) return;

    try {
      final response = await ApiService.post(
        '/admin/queues/$queueId/cancel',
        {'reason': reason},
      );
      if (response['success']) {
        _loadQueues();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Antrian berhasil dibatalkan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _addNote(int queueId) async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => _NoteDialog(),
    );

    if (note == null || note.isEmpty) return;

    try {
      final response = await ApiService.post(
        '/admin/queues/$queueId/note',
        {'note': note},
      );
      if (response['success']) {
        _loadQueues();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan berhasil ditambahkan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Antrian'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Department Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: DropdownButtonFormField<int>(
                    value: _selectedDepartmentId,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Poli',
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    items: _departments.map((dept) {
                      return DropdownMenuItem<int>(
                        value: dept['id'],
                        child: Text(dept['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartmentId = value;
                        _loadQueues();
                      });
                    },
                  ),
                ),
                // Queue List
                Expanded(
                  child: _queues.isEmpty
                      ? const Center(
                          child: Text('Tidak ada antrian'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _queues.length,
                          itemBuilder: (context, index) {
                            final queue = _queues[index];
                            return _buildQueueCard(queue);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildQueueCard(Map<String, dynamic> queue) {
    final status = queue['status'];
    final isCalled = status == 'called';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${queue['queue_number']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        queue['patient']['user']['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCalled ? 'Sedang Dipanggil' : 'Menunggu',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!isCalled)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callQueue(queue['id']),
                      icon: const Icon(Icons.campaign, size: 18),
                      label: const Text('Panggil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (isCalled) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completeQueue(queue['id']),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _skipQueue(queue['id']),
                    icon: const Icon(Icons.skip_next, size: 18),
                    label: const Text('Lewati'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addNote(queue['id']),
                    icon: const Icon(Icons.note_add, size: 18),
                    label: const Text('Catatan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelQueue(queue['id']),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Batal'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelDialog extends StatefulWidget {
  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Batalkan Antrian'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Alasan pembatalan',
          hintText: 'Masukkan alasan...',
        ),
        maxLines: 3,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alasan harus diisi')),
              );
              return;
            }
            Navigator.pop(context, _controller.text.trim());
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _NoteDialog extends StatefulWidget {
  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Catatan'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Catatan',
          hintText: 'Masukkan catatan...',
        ),
        maxLines: 3,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catatan harus diisi')),
              );
              return;
            }
            Navigator.pop(context, _controller.text.trim());
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
