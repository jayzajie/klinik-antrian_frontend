import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient/home_screen.dart';
import 'screens/patient/profile_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/patient_management_screen.dart';
import 'screens/admin/queue_settings_screen.dart';
import 'screens/admin/report_screen.dart';
import 'screens/admin/audit_log_screen.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Klinik Antrian',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin': (context) => const AdminDashboardScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/admin/patients': (context) => const PatientManagementScreen(),
          '/admin/queue-settings': (context) => const QueueSettingsScreen(),
          '/admin/report': (context) => const ReportScreen(),
          '/admin/audit-log': (context) => const AuditLogScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (auth.isAuthenticated) {
          // Route berdasarkan role
          if (auth.isAdmin) {
            return const AdminDashboardScreen();
          } else {
            return const HomeScreen();
          }
        }

        return const LoginScreen();
      },
    );
  }
}
