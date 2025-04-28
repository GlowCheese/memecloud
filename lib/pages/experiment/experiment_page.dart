import 'package:flutter/material.dart';
import 'package:memecloud/pages/experiment/e00.dart';
import 'package:memecloud/pages/experiment/e02.dart';


class ExperimentPage extends StatefulWidget {
  const ExperimentPage();

  @override
  State<ExperimentPage> createState() => _ExperimentPageState();
}

class _ExperimentPageState extends State<ExperimentPage> {
  @override
  Widget build(BuildContext context) {
    return E00(body: E02());
  }
}