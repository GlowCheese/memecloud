import 'package:flutter/material.dart';
import 'package:memecloud/blocs/gradient_bg/bg_cubit.dart';
import 'package:memecloud/components/default_appbar.dart';
import 'package:memecloud/components/mini_player.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/pages/dashboard/home_page.dart';
import 'package:memecloud/pages/dashboard/liked_songs_page.dart';
import 'package:memecloud/pages/dashboard/search/search_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final gradBg = getIt<BgCubit>();
    late final Map? appBarAndBody;

    switch (currentPageIndex) {
      case 0:
        gradBg.setColor('/dashboard', MyBgColorSet.purple);
        appBarAndBody = getHomePage(context);
        break;
      case 1:
        gradBg.setColor('/dashboard', MyBgColorSet.cyan);
        appBarAndBody = getSearchPage(context);
        break;
      case 2:
        gradBg.setColor('/dashboard', MyBgColorSet.redAccent);
        appBarAndBody = getLikedSongsPage(context);
      default:
        appBarAndBody = {
          'appBar': defaultAppBar(context, title: 'null'),
          'body': Placeholder()
        };
    }

    return Scaffold(
      appBar: appBarAndBody['appBar'],
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(Duration(seconds: 1));
        },
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            appBarAndBody['body'],
            getMiniPlayer()
          ]
        ),
      ),
      backgroundColor: Colors.transparent,
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Liked',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.warning_amber),
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
