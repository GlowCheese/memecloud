// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memecloud/blocs/gradient_bg/bg_cubit.dart';
import 'package:memecloud/core/getit.dart';

class E00 extends StatefulWidget {
  final Widget body;
  const E00({super.key, required this.body});

  @override
  State<E00> createState() => E00State();
}

class E00State extends State<E00> {
  Color color = Color.fromARGB(255, 128, 128, 128);
  late Color newColor = color;
  List<Color> timeline = [];
  late Timer timer;
  final random = Random();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (timeline.isEmpty) {
        newColor = Color.fromARGB(
          255,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );
        for (var i = 0; i < 10; i++) {
          timeline.add(
            Color.fromARGB(
              255,
              newColor.red + i * (color.red - newColor.red) ~/ 10,
              newColor.green + i * (color.green - newColor.green) ~/ 10,
              newColor.blue + i * (color.blue - newColor.blue) ~/ 10,
            ),
          );
        }
      }
      color = timeline.removeLast();
      getIt<BgCubit>().setColor('/experiment', color);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.body;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
