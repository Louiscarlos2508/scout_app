import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Widget toggle pour marquer la présence/absence d'un membre.
class AttendanceToggle extends StatelessWidget {
  final String memberName;
  final bool isPresent;
  final VoidCallback? onToggle;
  final bool enabled;

  const AttendanceToggle({
    super.key,
    required this.memberName,
    required this.isPresent,
    this.onToggle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(
          memberName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Switch(
          value: isPresent,
          onChanged: enabled && onToggle != null ? (_) => onToggle!() : null,
          activeColor: AppColors.success,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isPresent
                ? AppColors.success.withOpacity(0.2)
                : AppColors.error.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPresent ? Icons.check_circle : Icons.cancel,
            color: isPresent ? AppColors.success : AppColors.error,
          ),
        ),
        onTap: enabled && onToggle != null ? onToggle : null,
      ),
    );
  }
}
