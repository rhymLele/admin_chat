import 'package:admin_user/components/drawer/my_setting_title.dart';
import 'package:admin_user/helper/navigate_pages.dart';
import 'package:admin_user/theme/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
      ),
      body: Column(
        children: [
          MySettingTitle(
            title: "Dark Mode",
            action: CupertinoSwitch(
                onChanged: (value) =>
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleMode(),
                value: Provider.of<ThemeProvider>(context, listen: false)
                    .isDarkMode),
          ),
          MySettingTitle(
              title: "Account Setting",
              action: GestureDetector(
                onTap:()=> goToSettingAccount(context),
                child: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )),
        ],
      ),
    );
  }
}
