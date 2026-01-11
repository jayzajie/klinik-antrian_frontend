import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../display/queue_display_screen.dart';
import 'queue_management_screen.dart';
import 'reports_screen.dart';
import 'department_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final response = await ApiService.get('/admin/dashboard-stats');
      if (response['success'] && mounted) {
        setState(() {
          _stats = response['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: CustomScrollView(
                slivers: [
                  // Header dengan gradient
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.admin_panel_settings,
                                        color: AppTheme.primaryColor,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Admin Dashboard',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Selamat Datang,',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  authProvider.user?.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.tv, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QueueDisplayScreen(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () async {
                          await authProvider.logout();
                        },
                      ),
                    ],
                  ),
                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Cards
                          if (_stats != null) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Total Antrian Hari Ini',
                                    '${_stats!['today_total'] ?? 0}',
                                    Icons.people,
                                    AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    'Sedang Dilayani',
                                    '${_stats!['serving'] ?? 0}',
                                    Icons.medical_services,
                                    AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Menunggu',
                                    '${_stats!['waiting'] ?? 0}',
                                    Icons.schedule,
                                    AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    'Selesai',
                                    '${_stats!['completed'] ?? 0}',
                                    Icons.check_circle,
                                    AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Quick Actions
                          const Text(
                            'Menu Utama',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildMenuCard(
                            'Kelola Antrian',
                            'Panggil, lewati, atau selesaikan antrian',
                            Icons.queue,
                            AppTheme.primaryColor,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const QueueManagementScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            'Laporan Harian',
                            'Lihat statistik dan laporan antrian',
                            Icons.assessment,
                            AppTheme.primaryColor,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReportsScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            'Manajemen Poli',
                            'Kelola data poli/department',
                            Icons.business,
                            AppTheme.primaryColor,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DepartmentManagementScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            'Tampilan Antrian',
                            'Lihat tampilan antrian untuk pasien',
                            Icons.tv,
                            AppTheme.primaryColor,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const QueueDisplayScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            'Manajemen Pasien',
                            'Kelola data pasien',
                            Icons.people,
                            AppTheme.primaryColor,
                            () {
                              Navigator.pushNamed(context, '/admin/patients');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            'Pengaturan Antrian',
                            'Atur jam operasional & max antrian',
                            Icons.settings,
                            AppTheme.primaryColor,
                            () {
                              Navigator.pushNamed(context, '/admin/queue-settings');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            'Export Laporan PDF',
                            'Generate laporan antrian PDF',
                            Icons.picture_as_pdf,
                            AppTheme.primaryColor,
                            () {
                              Navigator.pushNamed(context, '/admin/report');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            'Audit Log',
                            'Lihat riwayat aktivitas admin',
                            Icons.history,
                            AppTheme.primaryColor,
                            () {
                              Navigator.pushNamed(context, '/admin/audit-log');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
