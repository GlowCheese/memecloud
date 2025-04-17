// ignore_for_file: file_names

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/presentation/ui/code_block.dart';

class PageNotFound extends StatelessWidget {
  final String routePath;

  const PageNotFound({super.key, required this.routePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Go Back', style: TextStyle(color: Colors.white)),
        leading: BackButton(
          onPressed: () {
            try {
              context.pop();
            } catch (e) {
              context.go('/404');
            }
          },
          color: Colors.white,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GifView.asset('assets/gifs/rick.gif', frameRate: 15),
          ),
          SizedBox(height: 10),
          Center(
            child: SelectableText.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 17,
                  color: AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                ),
                children: [
                  TextSpan(text: 'Page '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: CodeBlock(routePath),
                  ),
                  TextSpan(text: ' not found! 🙄'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
