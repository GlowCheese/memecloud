import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/presentation/ui/gradient_background.dart'
    show GradientBackground;

final Map<String, String> titleOf = {'/home': 'Welcome!', '/search': 'Search'};

Widget pageWithGradientBackground(
  BuildContext context,
  GoRouterState state,
  Widget body,
) {
  return Stack(children: [GradientBackground(state.fullPath), body]);
}
