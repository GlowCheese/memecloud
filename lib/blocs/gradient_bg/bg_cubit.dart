import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBgColorSet {
  static final cyan = Colors.cyan.shade900;
  static final purple = Colors.deepPurple.shade300;
  static final grey = Colors.blueGrey;
  static final redAccent = Colors.redAccent.shade200;
  static final teal = Colors.teal.shade600;
  static final indigo = Colors.indigo.shade400;
  static final orange = Colors.deepOrange.shade400;
  static final pink = Colors.pink.shade400;
  static final green = Colors.green.shade700;
  static final amber = Colors.amber.shade800;
  static final lightBlue = Colors.lightBlue.shade700;
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
