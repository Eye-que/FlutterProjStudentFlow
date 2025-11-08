import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/navigation_drawer.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../tasks/task_list_screen.dart';
import '../tasks/add_edit_task_screen.dart';
import '../settings/settings_screen.dart';
import '../account/account_screen.dart';
import 'dashboard_home_screen.dart';

/// Main Home Screen with Bottom Navigation
/// Contains Home, Tasks, Settings, Account tabs
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Load tasks when home screen initializes to ensure notifications are scheduled
    // This ensures notifications work from anywhere - dashboard, home, etc.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app comes to foreground, reschedule notifications
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 App resumed - rescheduling notifications');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (authProvider.user != null) {
        // Reschedule notifications immediately when app comes to foreground
        taskProvider.rescheduleNotifications();
      }
    }
  }

  void _loadTasks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (authProvider.user != null) {
      debugPrint('🏠 HomeScreen: Loading tasks to schedule notifications');
      taskProvider.loadTasks(authProvider.user!.uid);
    }
  }

  List<Widget> get _screens => [
    DashboardHomeScreen(onViewAllTasks: () => changeNavIndex(1)),
    const TaskListScreen(),
    const SettingsScreen(),
    const AccountScreen(),
  ];

  void changeNavIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Reload tasks when navigating to Tasks tab to ensure notifications are up-to-date
    if (index == 1) {
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Positioned(
                    right: 8,
                    top: 6,
                    child: Transform.rotate(
                      angle: -0.3,
                      child: Icon(
                        Icons.flash_on,
                        size: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'StudyFlow',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final taskProvider = Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  );

                  await Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AddEditTaskScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0.0, 1.0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                              child: child,
                            );
                          },
                    ),
                  );

                  // Refresh tasks after returning
                  if (authProvider.user != null) {
                    taskProvider.loadTasks(authProvider.user!.uid);
                  }
                },
                backgroundColor: const Color(0xFF3B82F6),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Task',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
