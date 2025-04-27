import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/blocs/gradient_background/gradient_cubit.dart';
import 'package:memecloud/core/getit.dart';

class GradientBackground extends StatelessWidget {
  final String? routerName;

  const GradientBackground(this.routerName, {super.key});

  @override
  Widget build(BuildContext context) {
    final bgCubit = getIt<GradientBgCubit>();
    final adaptiveTheme = AdaptiveTheme.of(context);
    final colorScheme = adaptiveTheme.theme.colorScheme;
    return BlocBuilder<GradientBgCubit, Color>(
      bloc: bgCubit,
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [state, colorScheme.surfaceDim],
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
