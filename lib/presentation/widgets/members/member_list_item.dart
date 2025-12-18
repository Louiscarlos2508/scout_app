import 'package:flutter/material.dart';

/// Élément de liste pour afficher un membre.
class MemberListItem extends StatelessWidget {
  final String name;
  final int age;
  final VoidCallback? onTap;

  const MemberListItem({
    super.key,
    required this.name,
    required this.age,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text('$age ans'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

