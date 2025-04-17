import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final pages = ['/home', '/search', '/trending'];

class DefaultNavigationBar extends StatelessWidget {
  const DefaultNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final path = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final currentPageIndex = pages.indexOf(path);

    return BottomNavigationBar(
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
        context.go(pages[index]);
      },
    );
  }
}
