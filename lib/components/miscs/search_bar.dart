import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MySearchBar extends StatefulWidget {
  /// Must be between `1` and `2`.
  final int variant;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextEditingController? searchQueryController;

  const MySearchBar({
    super.key,
    required this.variant,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.searchQueryController,
  });

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  late final searchQueryController =
      widget.searchQueryController ?? TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.variant == 1) {
      return _variant1(context);
    } else if (widget.variant == 2) {
      return _variant2(context);
    } else {
      return Placeholder();
    }
  }

  Widget _variant1(BuildContext context) {
    return SearchBar(
      controller: searchQueryController,
      hintText: 'Songs, Artists, Podcasts & More',
      hintStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 14, color: Colors.grey),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 15, color: Colors.black),
      ),
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SvgPicture.asset(
          'assets/icons/Search.svg',
          width: 25,
          height: 25,
        ),
      ),
      trailing: [
        if (searchQueryController.text.isNotEmpty)
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              searchQueryController.clear();
              widget.onChanged?.call(
                '',
              );
            },
          ),
      ],
      backgroundColor: WidgetStateProperty.all(Colors.white),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 8)),
    );
  }

  Widget _variant2(BuildContext context) {
    return SearchBar(
      controller: searchQueryController,
      hintText: 'Tìm kiếm bài hát',
      hintStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 14, color: Colors.grey),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 15, color: Colors.black),
      ),
      trailing: [
        SvgPicture.asset('assets/icons/Search.svg', width: 18, height: 18),
        SizedBox(width: 5),
      ],
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      backgroundColor: WidgetStateProperty.all(Colors.white),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 10)),
    );
  }
}
