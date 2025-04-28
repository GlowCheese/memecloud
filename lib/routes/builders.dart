import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/blocs/gradient_bg/bg_container.dart';


Widget pageWithGradientBackground(
  BuildContext context,
  GoRouterState state,
  Widget body,
) {
  return Stack(children: <Widget>[GradientBackground(state.fullPath), body]);
}