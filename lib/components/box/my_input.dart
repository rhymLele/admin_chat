import 'package:flutter/material.dart';

class MyInput extends StatelessWidget {
  const MyInput(
      {super.key,
      required this.text,
      required this.hint,
      required this.onTapText,
      required this.onTap});

  final TextEditingController text;
  final String hint;
  final void Function()? onTap;
  final String onTapText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: TextField(
        controller: text,
        maxLines: 3,
        maxLength: 140,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(12)
          ),
          focusedBorder:OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
              borderRadius: BorderRadius.circular(12)
          ),
          hintText: hint
            ,hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary
        ),filled: true,fillColor: Theme.of(context).colorScheme.secondary
        ),
      ),actions: [
        TextButton(onPressed: (){
          Navigator.pop(context);
          text.clear();
        }, child:const Text("Cancel")),
      TextButton(onPressed:(){
        Navigator.pop(context);
        onTap!();
        text.clear();
      }, child: const Text("Confirm"))
    ],
    );
  }
}
