import 'package:admin_user/features/home/pages/account_setting_page.dart';
import 'package:admin_user/features/home/pages/profile_page.dart';
import 'package:flutter/material.dart';


void goUserPage(BuildContext c,String uid){
  Navigator.push(c, MaterialPageRoute(builder: (c)=>ProfilePage(uid: uid)));
}


void goToSettingAccount(BuildContext c){
  Navigator.push(c, MaterialPageRoute(builder: (c)=>const AccountSettingPage()));

}