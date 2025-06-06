import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ArtistFollowButton extends StatefulWidget {
  final String artistId;
  final bool? isFollowing;
  final Function()? onPressed;

  const ArtistFollowButton({
    super.key,
    required this.artistId,
    this.isFollowing,
    this.onPressed,
  });

  @override
  State<ArtistFollowButton> createState() => _ArtistFollowButtonState();
}

class _ArtistFollowButtonState extends State<ArtistFollowButton> {
  bool? isFollowing;

  @override
  void initState() {
    super.initState();
    unawaited(
      getIt<ApiKit>().isFollowingArtist(widget.artistId).then((isFollowing) {
        setState(() => this.isFollowing = isFollowing);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    late final Widget? icon;
    late final Widget label;
    const textStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );

    if (isFollowing == true) {
      icon = null;
      label = const Text('Đang theo dõi', style: textStyle);
    } else {
      icon = const FaIcon(FontAwesomeIcons.userPlus);
      label = const Text('Theo dõi', style: textStyle);
    }

    if (isFollowing == null) {
      return Skeletonizer(
        child: OutlinedButton.icon(onPressed: null, icon: icon, label: label),
      );
    }

    return OutlinedButton.icon(
      icon: icon,
      label: label,
      onPressed: () {
        widget.onPressed?.call();
        setState(() => isFollowing = !isFollowing!);
        unawaited(getIt<ApiKit>().toggleFollowArtist(widget.artistId));
      },
    );
  }
}
