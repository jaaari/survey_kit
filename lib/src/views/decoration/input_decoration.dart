import 'package:flutter/material.dart';

InputDecoration textFieldInputDecoration({String hint = '', Color borderColor = const Color.fromARGB(255, 113, 113, 113), TextStyle hintStyle = const TextStyle()}) => InputDecoration(
      contentPadding: const EdgeInsets.only(
        left: 26,
        bottom: 26,
        top: 26,
        right: 26,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      hintText: hint,
      hintStyle: hintStyle,
    );
