import 'package:flutter/material.dart';
import 'package:memecloud/pages/experiment/e01.dart';
import 'package:memecloud/pages/experiment/e04.dart';
import 'package:memecloud/pages/experiment/e05.dart';
import 'package:memecloud/pages/experiment/e06.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';


final allPages = {
  'E01': () => E01(),
  'E04': () => E04(),
  'E05': () => E05(),
  'E06': () => E06(),
};

final pageController = ExperimentPageController();

Map getExperimentPage(BuildContext context) {
  return {
    'appBar': defaultAppBar(
      context,
      title: 'Experiment',
      iconUri: 'assets/icons/experiment-icon.png',
    ),
    'bgColor': MyColorSet.indigo,
    'body': _ExperimentPage(pageController),
    'floatingActionButton': _FloatingActionButton(pageController),
  };
}

class ExperimentPageController {
  void Function(String body)? setBody;
}

class _FloatingActionButton extends StatelessWidget {
  final ExperimentPageController controller;

  const _FloatingActionButton(this.controller);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: MyColorSet.orange,
      children:
          allPages.keys
              .map(
                (page) => SpeedDialChild(
                  child: Text(page),
                  // label: page,
                  onTap: () => controller.setBody!(page),
                ),
              )
              .toList(),
    );
  }
}

class _ExperimentPage extends StatefulWidget {
  final ExperimentPageController controller;

  const _ExperimentPage(this.controller);

  @override
  State<_ExperimentPage> createState() => _ExperimentPageState();
}

class _ExperimentPageState extends State<_ExperimentPage> {
  String bodyCode = 'E01';

  @override
  void initState() {
    super.initState();
    widget.controller.setBody =
        (body) => setState(() {
          bodyCode = body;
        });
  }

  @override
  Widget build(BuildContext context) {
    return allPages[bodyCode]!();
  }
}
