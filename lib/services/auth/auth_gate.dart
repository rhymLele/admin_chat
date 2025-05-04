/*


this is to check if user logged in or not
 */
import 'package:admin_user/features/auth/pages/auth_page.dart';
import 'package:admin_user/features/home/pages/admin_board.dart';
import 'package:admin_user/features/home/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if(snapshot.hasData)
            {
              return const AdminBoard();
            }else{
            return const AuthPage();
          }
        },
      ),
    );
  }
}
