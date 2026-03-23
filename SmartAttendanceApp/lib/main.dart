import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'providers/admin_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  final auth = AuthProvider();
  await auth.restoreSession();

  final api = ApiService(() async => auth.token);
  auth.bindApi(api);

  runApp(
    SmartAttendanceApp(
      auth: auth,
      api: api,
    ),
  );
}

class SmartAttendanceApp extends StatelessWidget {
  const SmartAttendanceApp({
    super.key,
    required this.auth,
    required this.api,
  });

  final AuthProvider auth;
  final ApiService api;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider<AttendanceProvider>(
          create: (_) => AttendanceProvider(api),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(api),
        ),
      ],
      child: MaterialApp(
        title: 'SmartAttendanceApp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          useMaterial3: true,
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

/// Admins use the dashboard for user management but still need check-in / check-out.
class _AdminHomeShell extends StatefulWidget {
  const _AdminHomeShell();

  @override
  State<_AdminHomeShell> createState() => _AdminHomeShellState();
}

class _AdminHomeShellState extends State<_AdminHomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        alignment: Alignment.topCenter,
        children: const [
          AttendanceScreen(),
          AdminDashboardScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fingerprint_outlined),
            selectedIcon: Icon(Icons.fingerprint),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }
        if (auth.isAdmin) {
          return const _AdminHomeShell();
        }
        return const AttendanceScreen();
      },
    );
  }
}
