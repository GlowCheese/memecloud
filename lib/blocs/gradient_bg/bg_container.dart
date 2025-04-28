import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/blocs/gradient_bg/bg_cubit.dart';
import 'package:memecloud/core/getit.dart';

class GradientBackground extends StatelessWidget {
  final String? routerName;

  const GradientBackground(this.routerName, {super.key});

  @override
  Widget build(BuildContext context) {
    final bgCubit = getIt<BgCubit>();
    final theme = AdaptiveTheme.of(context).theme;

    return BlocBuilder<BgCubit, String>(
      bloc: bgCubit,
      builder: (context, state) {
        final bgColor = bgCubit.getColor(routerName);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bgColor, theme.colorScheme.surfaceDim],
              stops: [0.0, 0.4],
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
            ),
          ),
        );
      },
    );
  }
}
