import 'package:admin_user/features/home/pages/admin_board.dart';
import 'package:admin_user/features/home/pages/admin_log_page.dart';
import 'package:admin_user/features/home/pages/home_page.dart';
import 'package:admin_user/features/home/pages/profile_page.dart';
import 'package:admin_user/features/home/pages/report_page.dart';
import 'package:admin_user/features/home/pages/setting_page.dart';
import 'package:admin_user/services/auth/auth_service.dart';
import 'package:flutter/material.dart';


import 'my_drawer_title.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),
              //home title
              MyDrawerTitle(
                title: "D A S H B O A R D",
                icon: Icons.home,
                onTap: () => Navigator.of(context).pop(),
              ),
               MyDrawerTitle(
                title: "U S E R S",
                icon: Icons.account_box_sharp,
                onTap: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePage()));
                  // Navigator.pop(context);
                }
              ),
               MyDrawerTitle(
                title: "R E P O R T S",
                icon: Icons.report,
                onTap: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportPage()));
                  // Navigator.pop(context);
                }
              ),
               MyDrawerTitle(
                title: "T R A C K E R",
                icon: Icons.report,
                onTap: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  AdminLogPage()));
                  // Navigator.pop(context);
                }
              ),
              //profile,
              MyDrawerTitle(
                title: "P R O F I L E",
                icon: Icons.person,
                onTap: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              uid: _auth.getCurrentUid(),
                            )));
                  // Navigator.pop(context);
                }
              ),
              
              //search
              //setting
              MyDrawerTitle(
                title: "S E T T I N G",
                icon: Icons.settings,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SettingPage())),
              ),
              const Spacer(),
              MyDrawerTitle(
                title: "L O G O U T",
                icon: Icons.logout,
                onTap: () {
                  _auth.logOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
