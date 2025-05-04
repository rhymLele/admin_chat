import 'package:admin_user/components/loading/my_loading_circle.dart';
import 'package:admin_user/services/auth/auth_service.dart';
import 'package:admin_user/services/database/database_service.dart';
import 'package:admin_user/services/logger/logger_service.dart';
import 'package:flutter/material.dart';


import '../components/my_button.dart';
import '../components/my_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.togglePages});

  final void Function()? togglePages;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final auth = AuthService();
  final db=DatabaseService();
  void login() async{
    final String email=emailController.text;
    final String pw=pwController.text;


    if(email.isNotEmpty&&pw.isNotEmpty)
    {
      showLoadingCircle(context);
     try{

      await auth.loginWithEmailPassword(email, pw);
      await LoggerService().logAdminAction('login', {'email': email});
      if(mounted) hideLoadingCircle(context);

     }catch(e)
    {
        if(mounted) hideLoadingCircle(context);
        if(mounted){
          showDialog(context: context, builder: (context)=>AlertDialog(title: Text(e.toString()),));
        }
    }
    }else
    {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email or Password cant be mt')));
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    pwController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo
                  Icon(
                    Icons.lock_open_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  //welcome back msg
                  Text(
                    "Welcome back, you've have been missed",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 30,
                  )
                  //email text field
                  ,
                  MyTextField(
                      controller: emailController,
                      hintText: "email",
                      obscureText: false),
                  const SizedBox(
                    height: 30,
                  ),
                  MyTextField(
                      controller: pwController,
                      hintText: "password",
                      obscureText: true),
                  //pw tf
                  const SizedBox(
                    height: 50,
                  ),
                  MyButton(onTap: login, text: "Sign In"),
                  //lg btn
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member? ",
                        style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      GestureDetector(
                        onTap: widget.togglePages,
                        child: Text(
                          " Already now",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      )
                    ],
                  ),

                  //reg btn
                ],
              ),
            ),
          )),
    );
  }
}