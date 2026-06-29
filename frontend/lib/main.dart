import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'admin/screens/admin_main_screen.dart';
import 'admin/screens/dashboard/admin_dashboard_screen.dart';
import 'admin/screens/reports/reports_screen.dart';
import 'auth/auth_service.dart';
import 'auth/login_screen.dart';
import 'kasir/constants/app_constants.dart';
import 'kasir/controllers/kasir_shell_controller.dart';
import 'kasir/screens/dashboard/dashboard_screen.dart';
import 'kasir/screens/member_management/member_management_screen.dart';
import 'kasir/screens/gym_transaction/gym_transaction_screen.dart';
import 'kasir/screens/food_beverage_transaction/food_beverage_transaction_screen.dart';
import 'kasir/screens/attendance/attendance_screen.dart';
import 'kasir/screens/attendance/member_check_in_screen.dart';
import 'kasir/screens/registration/member_register_screen.dart';
import 'kasir/screens/transaction_history/transaction_history_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Kunci orientasi ke landscape (perangkat mobile/tablet).
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'POS GYM - X-FIT Digital Indonesia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppColors.primaryColor),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(elevation: 2, centerTitle: true),
      ),
      home: LoginScreen(authRepository: authRepository),
      getPages: getRoutes(authRepository: authRepository),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final KasirShellController _shell = Get.put(KasirShellController());

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MemberManagementScreen(),
    const GymTransactionScreen(),
    const FoodBeverageTransactionScreen(),
    const AttendanceScreen(),
    const TransactionHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = _shell.tabIndex.value;
      return Scaffold(
        body: _screens[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: _shell.goTo,
          items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Member',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Gym',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'F&B',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Absensi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF071A3D),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        elevation: 12,
        ),
      );
    });
  }
}

List<GetPage> getRoutes({AuthRepository? authRepository}) => [
  GetPage(
    name: '/',
    page: () => LoginScreen(authRepository: authRepository),
  ),
  GetPage(name: '/kasir', page: () => const HomeScreen()),
  GetPage(name: '/admin', page: () => const AdminMainScreen()),
  GetPage(name: '/admin-dashboard', page: () => const AdminDashboardScreen()),
  GetPage(name: '/dashboard', page: () => const DashboardScreen()),
  GetPage(
    name: '/member-management',
    page: () => const MemberManagementScreen(),
  ),
  GetPage(name: '/gym-transaction', page: () => const GymTransactionScreen()),
  GetPage(
    name: '/food-beverage-transaction',
    page: () => const FoodBeverageTransactionScreen(),
  ),
  GetPage(name: '/attendance', page: () => const AttendanceScreen()),
  GetPage(name: '/member-check-in', page: () => const MemberCheckInScreen()),
  GetPage(name: '/member-register', page: () => const MemberRegisterScreen()),
  GetPage(
    name: '/transaction-history',
    page: () => const TransactionHistoryScreen(),
  ),
  GetPage(name: '/reports', page: () => const ReportsScreen()),
];
