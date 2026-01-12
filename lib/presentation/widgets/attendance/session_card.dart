import 'package:flutter/material.dart';
import '../../../domain/entities/attendance.dart';
import '../../theme/app_colors.dart';

/// Widget carte pour afficher une session de présence.
class SessionCard extends StatelessWidget {
  final Attendance session;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
  });

  String _getSessionTypeLabel(SessionType type) {
    switch (type) {
      case SessionType.weekly:
        return 'Hebdomadaire';
      case SessionType.monthly:
        return 'Mensuelle';
      case SessionType.special:
        return 'Activité spéciale';
    }
  }

  IconData _getSessionTypeIcon(SessionType type) {
    switch (type) {
      case SessionType.weekly:
        return Icons.event_repeat;
      case SessionType.monthly:
        return Icons.calendar_month;
      case SessionType.special:
        return Icons.star;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);
    
    if (sessionDate == today) {
      return "Aujourd'hui";
    } else if (sessionDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else if (sessionDate == today.add(const Duration(days: 1))) {
      return 'Demain';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = session.presentMemberIds.length;
    final absentCount = session.absentMemberIds.length;
    final totalCount = presentCount + absentCount;
    final presentPercentage = totalCount > 0 ? (presentCount / totalCount) : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getSessionTypeIcon(session.type),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(session.date),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSessionTypeLabel(session.type),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Présents',
                      presentCount.toString(),
                      AppColors.success,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Absents',
                      absentCount.toString(),
                      AppColors.error,
                      Icons.cancel,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Total',
                      totalCount.toString(),
                      AppColors.primary,
                      Icons.people,
                    ),
                  ),
                ],
              ),
              if (totalCount > 0) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: presentPercentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      presentPercentage >= 0.8
                          ? AppColors.success
                          : presentPercentage >= 0.5
                              ? AppColors.warning
                              : AppColors.error,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(presentPercentage * 100).toStringAsFixed(0)}% de présence',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
