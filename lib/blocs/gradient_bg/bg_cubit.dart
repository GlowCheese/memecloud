import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBgColorSet {
  static final cyan = Colors.cyan.shade900;
  static final purple = Colors.deepPurple.shade300;
  static final grey = Colors.blueGrey;
  static final redAccent = Colors.redAccent.shade200;
}

class BgCubit extends Cubit<String> {
  BgCubit() : super('');

  late Map<String, Color> colorMap = {};
  Color defaultColor = MyBgColorSet.grey;

  void setColor(String routeName, Color color) {
    colorMap[routeName] = color;
    emit('$routeName: $color');
  }

  Color getColor(String? routeName) {
    if (routeName == null) return defaultColor;
    return colorMap[routeName] ?? defaultColor;
  }
}
