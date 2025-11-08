import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stats Card Widget
/// Displays statistics in a visually appealing card format
class StatsCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 32,
                    ),
                  ),
                  Text(
                    count.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

