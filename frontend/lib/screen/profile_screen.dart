import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Profile {
  final String name;
  final String profileImageUrl;

  Profile({required this.name, required this.profileImageUrl});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['username'],
      profileImageUrl: json['profileImg'],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.profile, Key? key}) : super(key: key);
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final dummyProfile = Profile(
      name: "John Doe",
      profileImageUrl: "https://via.placeholder.com/150",
    );

    final displayProfile = profile ?? dummyProfile;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 125,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    profile.profileImageUrl,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Show Profile',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Account settings'),
                      const ProfileListTile(
                        label: 'Personal Information',
                        iconData: Icons.person_outline,
                      ),
                      const ProfileListTile(
                        label: 'Payments and payouts',
                        iconData: Icons.payments_outlined,
                      ),
                      const ProfileListTile(
                        label: 'Notifications',
                        iconData: Icons.notifications_outlined,
                      ),
                      _buildSectionTitle('Hosting'),
                      const ProfileListTile(
                        label: 'Learn about hosting',
                        iconData: Icons.home_outlined,
                      ),
                      const ProfileListTile(
                          label: 'List your space',
                          iconData: Icons.add_business_outlined),
                      const ProfileListTile(
                        label: 'Host an experience',
                        iconData: Icons.beach_access_outlined,
                      ),
                      _buildSectionTitle('Referrals & Credits'),
                      const ProfileListTile(
                        label: 'Gift cards',
                        subtitle: 'Send or redeem a gift card',
                        iconData: Icons.card_giftcard_outlined,
                      ),
                      const ProfileListTile(
                        label: 'Refer a Host',
                        subtitle: 'Earn \$15 for every new host you refer',
                        iconData: Icons.attach_money_outlined,
                      ),
                      _buildSectionTitle('Tools'),
                      const ProfileListTile(
                        label: 'Siri settings',
                        iconData: Icons.keyboard_voice_outlined,
                      ),
                      _buildSectionTitle('Support'),
                      const ProfileListTile(
                        label: 'How FlutterUI works',
                        iconData: Icons.card_travel_outlined,
                      ),
                      const ProfileListTile(
                        label: 'Safety Center',
                        subtitle:
                        'Get the support, tools, and information you need to be safe',
                        iconData: Icons.shield,
                      ),
                      const ProfileListTile(
                        label: 'Contact Neighborhood Support',
                        subtitle:
                        'Let our team know about concerns related to home sharing activity in your area.',
                        iconData: Icons.question_answer_outlined,
                      ),
                      const ProfileListTile(
                        label: 'Get help',
                        iconData: Icons.help_outline,
                      ),
                      const ProfileListTile(
                        label: 'Give us feedback',
                        iconData: Icons.feedback_outlined,
                      ),
                      _buildSectionTitle('Legal'),
                      const ProfileListTile(
                        label: 'Terms of Service',
                      ),
                      const SizedBox(height: 24),
                      const ProfileListTile(
                        label: 'Log out',
                        labelColor: Colors.teal,
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'VERSION 1.0.0',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String label) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class ProfileListTile extends StatelessWidget {
  const ProfileListTile(
      {required this.label,
        this.labelColor = Colors.black,
        this.subtitle,
        this.iconData,
        this.onTap,
        Key? key})
      : super(key: key);
  final String label;
  final Color labelColor;
  final String? subtitle;
  final IconData? iconData;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap as void Function()?,
          contentPadding: EdgeInsets.zero,
          title: Text(
            label,
            style: TextStyle(fontSize: 18, color: labelColor),
          ),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing: iconData != null
              ? Icon(
            iconData,
            color: Colors.grey[900],
            size: 36,
          )
              : null,
        ),
        const Divider(thickness: .75),
      ],
    );
  }
}

Future<Profile> fetchProfile(String token, Profile? user) async {
  if (user != null) return user;

  final url = Uri.parse('https://api.example.com/profile');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return Profile.fromJson(data);
  } else {
    throw Exception('Failed to load profile');
  }
}