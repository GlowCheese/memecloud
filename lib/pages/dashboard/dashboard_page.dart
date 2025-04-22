import 'package:flutter/material.dart';
import 'package:memecloud/components/mini_player.dart';
import 'package:memecloud/pages/404.dart';
import 'package:memecloud/pages/dashboard/home/home_page.dart';
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
    late final Map? appBarAndBody;
    switch (currentPageIndex) {
      case 0:
        appBarAndBody = getHomePage(context);
        break;
      case 1:
        appBarAndBody = getSearchPage(context);
        break;
      default:
        appBarAndBody = null;
    }

    if (appBarAndBody == null) {
      return PageNotFound(routePath: '/undefined');
    }

    return Scaffold(
      appBar: appBarAndBody['appBar'],
      body: appBarAndBody['body'],
      bottomSheet: getMiniPlayer(),
      backgroundColor: Colors.transparent,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Trending',
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
      ),
    );
  }
}
