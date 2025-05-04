import 'package:admin_user/services/auth/auth_service.dart';
import 'package:flutter/material.dart';


class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  confirmDelete(BuildContext context){

      showDialog(context: context, builder:( context)=>AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete this account?")
        ,
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () async {
            await AuthService().deleteAccount();

           Navigator.pushNamedAndRemoveUntil(context, '/', (route)=>false);

          }, child:const Text("Delete")),
        ],
      )

      );

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Account Setting"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: ()=>confirmDelete(context),
            child: Container(
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12)),
              child: const Text(
                "Delete Account",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
