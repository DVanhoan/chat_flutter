import 'package:flutter/material.dart';

class ReusableListTile extends StatelessWidget {
  final String label;
  final IconData? icon;
  const ReusableListTile({required this.label, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(label),
          trailing: icon != null ? Icon(icon) : null,
        ),
        Divider(),
      ],
    );
  }
}

class SectionList extends StatelessWidget {
  final String title;
  final List<ReusableListTile> items;
  const SectionList({required this.title, required this.items, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(title, style: TextStyle(fontSize: 14)),
        ),
        ...items,
      ],
    );
  }
}

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SectionList(
            title: 'Account Settings',
            items: [
              ReusableListTile(label: 'Personal Information', icon: Icons.person_outline),
              ReusableListTile(label: 'Change Password', icon: Icons.lock_outline),
            ],
          ),
          SectionList(
            title: 'Notifications',
            items: [
              ReusableListTile(label: 'Notification Settings', icon: Icons.notifications_outlined),
            ],
          ),
          SectionList(
            title: 'Support',
            items: [
              ReusableListTile(label: 'Help Center', icon: Icons.help_outline),
              ReusableListTile(label: 'Terms of Service', icon: Icons.description_outlined),
            ],
          ),
        ],
      ),
    );
  }
}
