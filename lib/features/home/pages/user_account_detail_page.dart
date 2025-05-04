import 'package:flutter/material.dart';
import 'package:admin_user/model/user_account.dart';

class UserAccountDetailPage extends StatelessWidget {
  final UserAccount user;

  const UserAccountDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${user.name}", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text("Email: ${user.email}"),
            Text("Phone: ${user.phoneNumber}"),
            Text("Status: ${user.status}"),
          ],
        ),
      ),
    );
  }
}
