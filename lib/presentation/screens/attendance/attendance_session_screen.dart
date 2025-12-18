import 'package:flutter/material.dart';

/// Écran de pointage de présence pour une session.
class AttendanceSessionScreen extends StatelessWidget {
  final String sessionId;

  const AttendanceSessionScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pointage de présence'),
      ),
      body: const Center(
        child: Text('Pointage de présence'),
      ),
    );
  }
}

