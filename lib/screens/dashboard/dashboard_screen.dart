import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/stats_card.dart';
import '../tasks/task_list_screen.dart';
import '../tasks/add_edit_task_screen.dart';
import '../study_tips/study_tips_screen.dart';
import '../analytics/analytics_screen.dart';

/// Dashboard Screen
/// Main screen showing statistics and navigation
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      taskProvider.loadTasks(authProvider.user!.uid);
    }
  }

  final List<Widget> _screens = [
    const _DashboardHome(),
    const TaskListScreen(),
    const StudyTipsScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            _loadTasks();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Tips',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddEditTaskScreen(),
                  ),
                ).then((_) => _loadTasks());
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            )
          : null,
    );
  }
}

/// Dashboard Home Widget
/// Shows statistics and quick actions
class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    if (authProvider.user == null) {
      return const Center(child: Text('Not authenticated'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await taskProvider.loadTasks(authProvider.user!.uid);
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Welcome, ${authProvider.user!.email?.split('@')[0] ?? 'Student'}!',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                tooltip: 'Logout',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Statistics Cards
                Consumer<TaskProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      children: [
                        StatsCard(
                          title: 'Total Tasks',
                          count: provider.totalTasks,
                          icon: Icons.assignment,
                          color: Colors.blue,
                          onTap: () {
                            // Navigate to tasks screen with filter
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                title: 'Completed',
                                count: provider.completedTasks,
                                icon: Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatsCard(
                                title: 'Pending',
                                count: provider.pendingTasks,
                                icon: Icons.pending,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _QuickActionCard(
                      icon: Icons.add_task,
                      title: 'Add Task',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddEditTaskScreen(),
                          ),
                        ).then((_) {
                          taskProvider.loadTasks(authProvider.user!.uid);
                        });
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.list,
                      title: 'View Tasks',
                      color: Colors.purple,
                      onTap: () {
                        // Navigate to tasks tab
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.lightbulb,
                      title: 'Study Tips',
                      color: Colors.amber,
                      onTap: () {
                        // Navigate to tips tab
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.analytics,
                      title: 'Analytics',
                      color: Colors.teal,
                      onTap: () {
                        // Navigate to analytics tab
                      },
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

