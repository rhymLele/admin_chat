import 'package:flutter/material.dart';
import 'package:admin_user/model/user_account.dart';

class UserAccountItem extends StatelessWidget {
  final UserAccount user;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<String> onChangePassword;
  const UserAccountItem({
    super.key,
    required this.user,
    required this.onTap,
    required this.onDelete,  required this.onChangePassword,
  });
  void _promptChangePassword(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Change password for ${user.name}"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New password'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onChangePassword(controller.text);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }
void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to delete ${user.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
         trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') _confirmDelete(context);
            if (value == 'change_password') _promptChangePassword(context);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'delete', child: Text("Delete")),
            const PopupMenuItem(value: 'change_password', child: Text("Change Password")),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
