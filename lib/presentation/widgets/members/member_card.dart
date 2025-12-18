import 'package:flutter/material.dart';

/// Carte affichant les informations d'un membre.
class MemberCard extends StatelessWidget {
  final String name;
  final int age;
  final VoidCallback? onTap;

  const MemberCard({
    super.key,
    required this.name,
    required this.age,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text('$age ans'),
        onTap: onTap,
      ),
    );
  }
}

