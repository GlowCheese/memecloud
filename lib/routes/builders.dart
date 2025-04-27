import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/blocs/gradient_background/gradient_container.dart';


Widget pageWithGradientBackground(
  BuildContext context,
  GoRouterState state,
  Widget body,
) {
  return Stack(children: [GradientBackground(state.fullPath), body]);
}