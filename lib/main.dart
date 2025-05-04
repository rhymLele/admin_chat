import 'package:admin_user/firebase_options.dart';
import 'package:admin_user/services/auth/auth_gate.dart';
import 'package:admin_user/services/database/database_provider.dart';
import 'package:admin_user/theme/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context)=>ThemeProvider()),
    ChangeNotifierProvider(create: (context)=>DatabaseProvider()),

  ],child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute:  '/',
      routes: {
        '/':(context)=> const AuthGate()
      },
    );
  }
}
