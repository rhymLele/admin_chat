import 'package:admin_user/components/loading/my_loading_circle.dart';
import 'package:admin_user/services/auth/auth_service.dart';
import 'package:admin_user/services/database/database_service.dart';
import 'package:flutter/material.dart';




import '../components/my_button.dart';
import '../components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.togglePages});

  final void Function()? togglePages;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final cfpwController = TextEditingController();
  final pwController = TextEditingController();
  final auth = AuthService();
  final db= DatabaseService();
  void register() async{
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = pwController.text;
    final String cfpw = cfpwController.text;

    // final auCubit = context.read<AuthCubit>();

    if (name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        cfpw.isNotEmpty) {
      if (password == cfpw) {
        showLoadingCircle(context);
        try{

          await auth.registerWithEmailPassword(email, password);
          if(mounted) hideLoadingCircle(context);
          await db.saveUserInforInFB(name: name, email: email);
        }catch(e)
        {
          if(mounted) hideLoadingCircle(context);
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Password do not match with confirmpw')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Input fields cant be mt')));
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    cfpwController.dispose();
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
                "Let's create an account for you",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 16),
              ),
              const SizedBox(
                height: 30,
              )
              //email text field
              ,
              MyTextField(
                  controller: nameController,
                  hintText: "name",
                  obscureText: false),
              const SizedBox(
                height: 30,
              ),
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
              const SizedBox(
                height: 30,
              ),
              MyTextField(
                  controller: cfpwController,
                  hintText: "confirm password",
                  obscureText: true),
              //pw tf
              const SizedBox(
                height: 50,
              ),
              MyButton(onTap: register, text: "Register"),
              //lg btn

              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already a member? ",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: Text(
                      "Login now",
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
