import 'package:admin_user/features/account/user_account_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_user/components/drawer/my_drawer.dart';
import 'package:admin_user/model/user_account.dart';
import 'package:admin_user/services/database/database_provider.dart';
import 'user_account_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  List<UserAccount> filteredAccounts = [];

  late final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  @override
  void initState() {
    super.initState();
    dbProvider.fetchAllUserAccounts().then((_) {
      setState(() {
        filteredAccounts = dbProvider.allAccounts;
      });
    });

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredAccounts = dbProvider.allAccounts.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.status.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final newUser = UserAccount(
                  name: nameController.text,
                  email: emailController.text,
                  phoneNumber: phoneController.text,
                  status: 'active',
                  password: '@user123');
              await dbProvider.addUserAccount(newUser);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = listeningProvider.allAccounts.length;
    final active =
        listeningProvider.allAccounts.where((u) => u.status == 'active').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
              onPressed: _showAddUserDialog, icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total users: $total",
                    style: Theme.of(context).textTheme.titleMedium),
                Text("Active users: $active"),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // LIST
          Expanded(
            child: buildAllUserAccounts(filteredAccounts),
          ),
        ],
      ),
    );
  }

  Future<void> refreshUserList() async {
    await dbProvider.fetchAllUserAccounts();
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredAccounts = dbProvider.allAccounts.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.status.toLowerCase().contains(query);
      }).toList();
    });
  }

  Widget buildAllUserAccounts(List<UserAccount> users) {
    return users.isEmpty
        ? const Center(child: Text("No users found"))
        : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserAccountItem(
                user: user,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserAccountDetailPage(user: user),
                    ),
                  );
                },
                onDelete: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );
                  await dbProvider.deleteUserAccount(user);
                  Navigator.pop(context); // close loading
                  await refreshUserList();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User deleted")));
                },
                onChangePassword: (newPassword) async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );
                  await dbProvider.updateUserPassword(user, newPassword);
                  Navigator.pop(context); // close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password updated")));
                },
              );
            },
          );
  }
}
