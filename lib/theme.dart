import "package:flutter/material.dart";

  ThemeData theme() {
    return ThemeData(
      appBarTheme: appBarTheme(),
      inputDecorationTheme: inputDecorationTheme(),
      visualDensity: VisualDensity.adaptivePlatformDensity,

    );
  }

  AppBarTheme appBarTheme() {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
    );
  }

  InputDecorationTheme inputDecorationTheme() {
    OutlineInputBorder outlineInputDecoration = OutlineInputBorder(
      borderRadius: BorderRadius.circular(38),
      borderSide: BorderSide(color: Colors.black, width: 1),
      gapPadding: 10
    );

    return InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 26, vertical: 22),
      border: outlineInputDecoration,
      focusedBorder: outlineInputDecoration,
      enabledBorder: outlineInputDecoration
    );

  }


