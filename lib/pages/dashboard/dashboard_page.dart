import 'package:flutter/material.dart';
import 'package:memecloud/components/mini_player.dart';
import 'package:memecloud/pages/404.dart';
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
    late final Map? appBarAndBody;
    switch (currentPageIndex) {
      case 0:
        appBarAndBody = getHomePage(context);
        break;
      case 1:
        appBarAndBody = getSearchPage(context);
        break;
      case 2:
        appBarAndBody = getLikedSongsPage(context);
      default:
        appBarAndBody = null;
    }

    if (appBarAndBody == null) {
      return PageNotFound(routePath: '/undefined');
    }

    return Scaffold(
      appBar: appBarAndBody['appBar'],
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: appBarAndBody['body'],
      ),
      bottomSheet: getMiniPlayer(),
      backgroundColor: Colors.transparent,
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Future<void> _handleRefresh() async {
    // Chỗ này mày viết code load lại dữ liệu
    setState(() {});
    await Future.delayed(Duration(seconds: 1)); // Ví dụ chờ 2s
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
