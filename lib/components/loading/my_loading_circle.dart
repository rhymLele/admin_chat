import 'package:flutter/material.dart';
void showLoadingCircle(BuildContext c)
{
  showDialog(context: c, builder: (c)=> const AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Center(
      child: CircularProgressIndicator(),
    ),
  ));
}
void hideLoadingCircle(BuildContext c)
{
  Navigator.pop(c);
}