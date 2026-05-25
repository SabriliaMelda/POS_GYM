import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'constants/app_constants.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/member_management/member_management_screen.dart';
import 'screens/gym_transaction/gym_transaction_screen.dart';
import 'screens/food_beverage_transaction/food_beverage_transaction_screen.dart';
import 'screens/attendance/attendance_screen.dart';
import 'screens/transaction_history/transaction_history_screen.dart';
import 'screens/reports/reports_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const HomeScreen(),
      getPages: getRoutes,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MemberManagementScreen(),
    const GymTransactionScreen(),
    const FoodBeverageTransactionScreen(),
    const AttendanceScreen(),
    const TransactionHistoryScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Members',
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
            label: 'Attend',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0F766E),
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
  }
}

// Define routes
final List<GetPage> getRoutes = [
  GetPage(name: '/', page: () => const HomeScreen()),
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
  GetPage(
    name: '/transaction-history',
    page: () => const TransactionHistoryScreen(),
  ),
  GetPage(name: '/reports', page: () => const ReportsScreen()),
];
