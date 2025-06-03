import 'package:flutter/material.dart';
import 'package:memecloud/pages/experiment/e01.dart';
import 'package:memecloud/pages/experiment/e04.dart';
import 'package:memecloud/pages/experiment/e05.dart';
import 'package:memecloud/pages/experiment/e11.dart';
import 'package:memecloud/pages/experiment/e12.dart';
import 'package:memecloud/pages/experiment/e13.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/pages/experiment/e14.dart';
import 'package:memecloud/pages/experiment/e15.dart';
import 'package:memecloud/pages/experiment/e17.dart';
// import 'package:memecloud/pages/artist/artist_page.dart';

final allPages = {
  'E01': () => const E01(),
  'E04': () => const E04(),
  'E05': () => const E05(),
  'E11': () => const E11(),
  'E12': () => const E12(),
  'E13': () => const E13(),
  'E14': () => const E14(),
  'E15': () => const ArtistPage(artistAlias: 'Son-Tung-M-TP'),
  'E17': () => const ArtistPage17(artistAlias: 'Son-Tung-M-TP'),

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
