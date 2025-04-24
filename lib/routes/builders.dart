import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/components/gradient_background.dart';


Widget pageWithGradientBackground(
  BuildContext context,
  GoRouterState state,
  Widget body,
) {
  return Stack(children: [GradientBackground(state.fullPath), body]);
}