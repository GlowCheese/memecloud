import 'package:flutter/material.dart';
import 'package:memecloud/pages/dashboard/home_page.dart';
import 'package:memecloud/pages/library/library_page.dart';
import 'package:memecloud/pages/dashboard/search_page.dart';
import 'package:memecloud/components/song/mini_player.dart';
import 'package:memecloud/pages/dashboard/top_chart_page.dart';
import 'package:memecloud/components/miscs/default_appbar.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/pages/experiment/experiment_page.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    late final Map? scaffElems;

    switch (currentPageIndex) {
      case 0:
        scaffElems = getHomePage(context);
        break;
      case 1:
        scaffElems = getSearchPage(context);
        break;
      case 2:
        scaffElems = getTopChartPage(context);
        break;
      case 3:
        scaffElems = getLibraryPage(context);
        break;
      case 4:
        scaffElems = getExperimentPage(context);
        break;
      default:
        scaffElems = {
          'appBar': defaultAppBar(context, title: 'null'),
          'bgColor': MyColorSet.grey,
          'body': const Placeholder(),
        };
    }

    return GradBackground(
      color: scaffElems['bgColor'],
      child: Scaffold(
        appBar: scaffElems['appBar'],
        body: scaffElems['body'],
        floatingActionButton: scaffElems['floatingActionButton'],
        backgroundColor: Colors.transparent,
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        MiniPlayer(),
        SnakeNavigationBar.color(
          snakeShape: SnakeShape.circle,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          snakeViewColor: Colors.indigo.shade400,

          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: currentPageIndex,
          onTap: (index) => setState(() => currentPageIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.library_music), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.bubble_chart), label: ''),
          ],
        ),
        // NavigationBar(
        //   selectedIndex: currentPageIndex,
        //   onDestinationSelected:
        //   destinations: const [
        //   ],
        // ),
      ],
    );
  }
}
