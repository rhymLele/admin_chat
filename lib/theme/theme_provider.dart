import 'package:admin_user/theme/dark_mode.dart';
import 'package:admin_user/theme/light_mode.dart';
import 'package:flutter/material.dart';


class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData value) {
    _themeData = value;
    notifyListeners();
  }
  void toggleMode(){

    if(_themeData==lightMode){
      themeData=darkMode;
    }else{
      themeData=lightMode;
    }
  }


}
