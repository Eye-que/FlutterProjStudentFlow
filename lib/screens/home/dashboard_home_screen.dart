import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';

/// Dashboard Home Screen
/// Shows task statistics and summary with modern gradient design
class DashboardHomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllTasks;

  const DashboardHomeScreen({super.key, this.onViewAllTasks});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (authProvider.user == null) {
      return const Center(child: Text('Not authenticated'));
    }

    // Get recent tasks (last 3)
    final recentTasks = taskProvider.tasks.take(3).toList();
    final todayTasks = taskProvider.tasksDueToday;
    final upcomingCount = taskProvider.upcomingDeadlines;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF3B82F6).withOpacity(0.2),
                  const Color(0xFF10B981).withOpacity(0.1),
                  colorScheme.surface,
                ]
              : [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF10B981).withOpacity(0.05),
                  const Color(0xFFF9FAFB),
                ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await taskProvider.loadTasks(authProvider.user!.uid);
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Welcome header with curved container
              SliverToBoxAdapter(
                child: _WelcomeHeader(
                  firstName: (authProvider.userFullName?.isNotEmpty ?? false)
                      ? authProvider.userFullName!.split(' ').first
                      : 'Student',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),
                    // Animated Summary Cards
                    Consumer<TaskProvider>(
                      builder: (context, provider, _) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _AnimatedStatsCard(
                                    title: '📝 Total',
                                    count: provider.totalTasks,
                                    icon: Icons.assignment,
                                    gradientColors: [
                                      const Color(0xFF3B82F6),
                                      const Color(0xFF06B6D4),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _AnimatedStatsCard(
                                    title: '✅ Completed',
                                    count: provider.completedTasks,
                                    icon: Icons.check_circle,
                                    gradientColors: [
                                      const Color(0xFF10B981),
                                      const Color(0xFF34D399),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _AnimatedStatsCard(
                                    title: '⏳ Pending',
                                    count: provider.pendingTasks,
                                    icon: Icons.timer,
                                    gradientColors: [
                                      const Color(0xFFF59E0B),
                                      const Color(0xFFFBBF24),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _AnimatedStatsCard(
                                    title: '📅 Upcoming',
                                    count: upcomingCount,
                                    icon: Icons.calendar_today,
                                    gradientColors: [
                                      const Color(0xFF8B5CF6),
                                      const Color(0xFFA78BFA),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    // Progress Chart
                    if (taskProvider.totalTasks > 0) ...[
                      Builder(
                        builder: (context) {
                          final colorScheme = Theme.of(context).colorScheme;
                          return Text(
                            'Progress Overview',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _ProgressChart(
                        total: taskProvider.totalTasks,
                        completed: taskProvider.completedTasks,
                      ),
                      const SizedBox(height: 32),
                    ],
                    // Today's Tasks Section
                    if (todayTasks.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          final colorScheme = Theme.of(context).colorScheme;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Today\'s Tasks',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              TextButton(
                                onPressed: widget.onViewAllTasks,
                                child: Text(
                                  'View All →',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: todayTasks.length,
                          itemBuilder: (context, index) {
                            return _TodayTaskCard(task: todayTasks[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    // Recent Tasks Section
                    Builder(
                      builder: (context) {
                        final colorScheme = Theme.of(context).colorScheme;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Tasks',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            TextButton(
                              onPressed: widget.onViewAllTasks,
                              child: Text(
                                'View All →',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Recent Tasks List
                    if (recentTasks.isEmpty && todayTasks.isEmpty)
                      _EmptyTasksState()
                    else if (recentTasks.isEmpty)
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final colorScheme = theme.colorScheme;
                          return Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withOpacity(0.1),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Text(
                              'No recent tasks',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      )
                    else
                      ...recentTasks.map((task) => _RecentTaskCard(task: task)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Welcome Header with Curved Container
class _WelcomeHeader extends StatelessWidget {
  final String firstName;

  const _WelcomeHeader({required this.firstName});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 Dashboard Header - Displaying firstName: $firstName');
    return ClipPath(
      clipper: _CurvedClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 60, 32, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF3B82F6), const Color(0xFF10B981)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $firstName 👋',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s your progress today',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Clipper for Curved Top
class _CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Animated Stats Card
class _AnimatedStatsCard extends StatefulWidget {
  final String title;
  final int count;
  final IconData icon;
  final List<Color> gradientColors;

  const _AnimatedStatsCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.gradientColors,
  });

  @override
  State<_AnimatedStatsCard> createState() => _AnimatedStatsCardState();
}

class _AnimatedStatsCardState extends State<_AnimatedStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.gradientColors[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              '${widget.count}',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress Chart (Donut)
class _ProgressChart extends StatefulWidget {
  final int total;
  final int completed;

  const _ProgressChart({required this.total, required this.completed});

  @override
  State<_ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<_ProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sections: _buildSections(),
              sectionsSpace: 2,
              centerSpaceRadius: 60.0,
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final completed = widget.completed;
    final pending = widget.total - widget.completed;

    return [
      if (completed > 0)
        PieChartSectionData(
          value: completed.toDouble(),
          color: const Color(0xFF10B981),
          radius: 50 * _controller.value,
          title: '',
        ),
      if (pending > 0)
        PieChartSectionData(
          value: pending.toDouble(),
          color: const Color(0xFFE5E7EB),
          radius: 50 * _controller.value,
          title: '',
        ),
    ];
  }
}

/// Recent Task Card
class _RecentTaskCard extends StatelessWidget {
  final Task task;

  const _RecentTaskCard({required this.task});

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'Low':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadline = task.deadline;
    final isOverdue =
        deadline.isBefore(DateTime.now()) && task.status == 'Pending';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? Colors.red.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: task.status == 'Completed'
                ? TextDecoration.lineThrough
                : null,
            color: task.status == 'Completed'
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.book, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  task.subject,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(deadline),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : colorScheme.onSurfaceVariant,
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('hh:mm a').format(deadline),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isOverdue ? Colors.red : colorScheme.onSurfaceVariant,
                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getPriorityColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            task.priority,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getPriorityColor(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Today's Task Card (Horizontal)
class _TodayTaskCard extends StatelessWidget {
  final Task task;

  const _TodayTaskCard({required this.task});

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'Low':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeOfDay = DateFormat('hh:mm a').format(task.deadline);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getPriorityColor().withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.subject,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getPriorityColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  timeOfDay,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.priority,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(),
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

/// Empty Tasks State with Lottie
class _EmptyTasksState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: 80,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up! 🎉',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tasks to display.\nAdd a new task to get started!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
