import 'package:flutter/material.dart';

/// Widget toggle pour marquer la présence/absence d'un membre.
class AttendanceToggle extends StatelessWidget {
  final String memberName;
  final bool isPresent;
  final ValueChanged<bool> onChanged;

  const AttendanceToggle({
    super.key,
    required this.memberName,
    required this.isPresent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(memberName),
      subtitle: Text(isPresent ? 'Présent' : 'Absent'),
      value: isPresent,
      onChanged: onChanged,
    );
  }
}

