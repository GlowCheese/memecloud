import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.cyan[700],
  primarySwatch: Colors.cyan,
  colorScheme: ColorScheme.dark(
    primary: Colors.cyan[700]!,
    secondary: Colors.cyanAccent[400]!,
    surface: Colors.grey[900]!,
    error: Colors.red[400]!,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    onError: Colors.black,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.cyan[700],
    foregroundColor: Colors.white,
  ),
  cardTheme: CardTheme(
    color: Colors.grey[900],
    elevation: 1,
    margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.cyan[700],
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  iconTheme: IconThemeData(color: Colors.cyan[300]),
  fontFamily: 'Poppins',
);
