import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';

/// Analytics Screen
/// Shows completion percentage per subject
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final analytics = provider.getAnalytics(authProvider.user!.uid);

          if (analytics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No analytics available yet.\nCreate some tasks to see your progress!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadTasks(authProvider.user!.uid);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Progress',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              label: 'Total',
                              value: provider.totalTasks.toString(),
                              icon: Icons.assignment,
                              color: Colors.blue,
                            ),
                            _StatItem(
                              label: 'Completed',
                              value: provider.completedTasks.toString(),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                            _StatItem(
                              label: 'Pending',
                              value: provider.pendingTasks.toString(),
                              icon: Icons.pending,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: provider.totalTasks > 0
                              ? provider.completedTasks / provider.totalTasks
                              : 0,
                          backgroundColor: Colors.grey[200],
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${provider.totalTasks > 0 ? ((provider.completedTasks / provider.totalTasks) * 100).toStringAsFixed(1) : 0}% Complete',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Subject-wise Analytics
                Text(
                  'Completion by Subject',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ...analytics.entries.map((entry) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.book, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getProgressColor(entry.value)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${entry.value.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: _getProgressColor(entry.value),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: entry.value / 100,
                              backgroundColor: Colors.grey[200],
                              minHeight: 8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(entry.value),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

/// Stat Item Widget for Analytics
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

