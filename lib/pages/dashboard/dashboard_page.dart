import 'package:flutter/material.dart';
import 'package:memecloud/components/mini_player.dart';
import 'package:memecloud/components/default_appbar.dart';
import 'package:memecloud/pages/dashboard/home_page.dart';
import 'package:memecloud/components/grad_background.dart';
import 'package:memecloud/pages/dashboard/liked_songs_page.dart';
import 'package:memecloud/pages/experiment/experiment_page.dart';
import 'package:memecloud/pages/dashboard/search_page.dart';

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
        scaffElems = getLikedSongsPage(context);
        break;
      case 3:
        scaffElems = getExperimentPage(context);
        break;
      default:
        scaffElems = {
          'appBar': defaultAppBar(context, title: 'null'),
          'bgColor': MyColorSet.grey,
          'body': Placeholder(),
        };
    }

    return GradBackground(
      color: scaffElems['bgColor'],
      child: Scaffold(
        appBar: scaffElems['appBar'],
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(Duration(seconds: 1));
          },
          child: Column(
            children: <Widget>[
              Expanded(child: scaffElems['body']),
              Stack(
                children: [
                  Padding(padding: EdgeInsets.all(8)),
                  getMiniPlayer(),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: scaffElems['floatingActionButton'],
        backgroundColor: Colors.transparent,
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Liked'),
        BottomNavigationBarItem(
          icon: Icon(Icons.bubble_chart),
          label: 'Experiment',
        ),
      ],
      currentIndex: currentPageIndex,
      selectedItemColor: const Color(0xFF1976D2),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      onTap: (index) {
        setState(() {
          currentPageIndex = index;
        });
      },
    );
  }
}
