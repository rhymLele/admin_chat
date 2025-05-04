import 'package:flutter/material.dart';
class MySettingTitle extends StatelessWidget {
  const MySettingTitle({super.key, required this.title, required this.action});
  final String title;
  final Widget action;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12)
      ),
      margin:const EdgeInsets.only(left: 25,right: 25,top:10),
      child: ListTile(
          title: Text(title),
      trailing: action),
    );
  }
}
