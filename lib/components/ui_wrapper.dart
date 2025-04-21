import 'package:flutter/material.dart';
import 'package:memecloud/components/default_navigation_bar.dart';

class UiWrapper extends StatelessWidget {
  final Widget? appBar;
  final Widget? bottomSheet;
  final Widget? bottomNavigationBar;
  final Widget body;

  const UiWrapper({
    super.key,
    this.appBar,
    this.bottomSheet,
    this.bottomNavigationBar,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar as AppBar?,
      body: body,
      bottomSheet: bottomSheet,
      bottomNavigationBar: bottomNavigationBar ?? DefaultNavigationBar(),
    );
  }
}
