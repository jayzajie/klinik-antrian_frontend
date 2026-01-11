import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/admin_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _dateFrom = DateTime.now().subtract(const Duration(days: 7));
  DateTime _dateTo = DateTime.now();
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final result = await AdminService.getReportData(
        DateFormat('yyyy-MM-dd').format(_dateFrom),
        DateFormat('yyyy-MM-dd').format(_dateTo),
      );
      setState(() {
        _reportData = result;
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

  Future<void> _generatePdf() async {
    if (_reportData == null) return;

    final pdf = pw.Document();
    final stats = _reportData!['stats'];
    final queues = _reportData!['queues'] as List;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('LAPORAN ANTRIAN KLINIK', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text('Periode: ${DateFormat('dd MMM yyyy').format(_dateFrom)} - ${DateFormat('dd MMM yyyy').format(_dateTo)}'),
          pw.SizedBox(height: 20),
          pw.Text('RINGKASAN', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            data: [
              ['Total Antrian', stats['total'].toString()],
              ['Menunggu', stats['waiting'].toString()],
              ['Dipanggil', stats['called'].toString()],
              ['Selesai', stats['done'].toString()],
              ['Dibatalkan', stats['cancelled'].toString()],
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('DETAIL ANTRIAN', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['No', 'Tanggal', 'No. Antrian', 'Pasien', 'Poli', 'Status'],
            data: queues.asMap().entries.map((entry) {
              final idx = entry.key;
              final q = entry.value;
              return [
                (idx + 1).toString(),
                q['queue_date'],
                q['queue_number'],
                q['patient']?['user']?['name'] ?? '-',
                q['department']?['name'] ?? '-',
                q['status'],
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Date From'),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(_dateFrom)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateFrom,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _dateFrom = date);
                      },
                    ),
                    ListTile(
                      title: const Text('Date To'),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(_dateTo)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateTo,
                          firstDate: _dateFrom,
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _dateTo = date);
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadReport,
                      icon: const Icon(Icons.search),
                      label: const Text('Generate Report'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_reportData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Summary', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      _buildStatRow('Total', _reportData!['stats']['total']),
                      _buildStatRow('Waiting', _reportData!['stats']['waiting']),
                      _buildStatRow('Called', _reportData!['stats']['called']),
                      _buildStatRow('Done', _reportData!['stats']['done']),
                      _buildStatRow('Cancelled', _reportData!['stats']['cancelled']),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _generatePdf,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export to PDF'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value.toString(), style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
