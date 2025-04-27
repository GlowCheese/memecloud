import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class MyBgColorSet {
  static final cyan = Colors.cyan.shade900;
  static final purple = Colors.deepPurple.shade300;
  static final grey = Colors.blueGrey;
  static final redAccent = Colors.redAccent.shade200;
}


class GradientBgCubit extends Cubit<Color> {
  GradientBgCubit() : super(MyBgColorSet.cyan);

  void setColor(Color color) => emit(color);
}