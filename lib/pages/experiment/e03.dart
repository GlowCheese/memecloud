import 'package:flutter/material.dart';
import 'package:memecloud/pages/experiment/e02.dart';

class E03 extends StatefulWidget {
  const E03({super.key});

  @override
  State<E03> createState() => _E03State();
}

class _E03State extends State<E03> {
  String? currentSearchQuery;
  late TextEditingController searchQueryController;

  @override
  void initState() {
    super.initState();
    searchQueryController = TextEditingController();
  }

  @override
  void dispose() {
    searchQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentSearchQuery == null) {
      return searchBar();
    }

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column (
      children: [searchBar(), E02(queryString: currentSearchQuery)],
      )
    );
  }

  Padding searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchQueryController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        onSubmitted: (value) {
          setState(() => currentSearchQuery = value);
        },
      ),
    );
  }
}
