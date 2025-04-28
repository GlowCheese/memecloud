import 'package:flutter/material.dart';
import 'package:memecloud/components/default_appbar.dart';
import 'package:memecloud/pages/experiment/e00.dart';
import 'package:memecloud/pages/experiment/e02.dart';


Map getExperimentPage(BuildContext context) {
  return {
    'body': _ExperimentPage(),
    'appBar': defaultAppBar(context, title: 'Experiment')
  };
}


class _ExperimentPage extends StatefulWidget {
  const _ExperimentPage();

  @override
  State<_ExperimentPage> createState() => _ExperimentPageState();
}

class _ExperimentPageState extends State<_ExperimentPage> {
  @override
  Widget build(BuildContext context) {
    return E00(body: E02());
  }
}