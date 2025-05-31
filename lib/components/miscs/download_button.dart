import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memecloud/blocs/dl_status/dl_status_enum.dart';

class DownloadButton extends StatelessWidget {
  final DlStatus status;
  final Duration transitionDuration;
  final double? iconSize;
  final Function() onPressed;
  final double? downloadProgress;

  const DownloadButton({
    super.key,
    required this.status,
    this.transitionDuration = const Duration(milliseconds: 350),
    this.iconSize,
    this.downloadProgress,
    required this.onPressed,
  });

  bool get isDownloaded => status == DlStatus.downloaded;
  bool get isDownloading => status == DlStatus.downloading;
  bool get isFetching => status == DlStatus.fetchingDownload;
  bool get isNotDownloaded => status == DlStatus.notDownloaded;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: isNotDownloaded ? 1 : 0,
          curve: Curves.ease,
          duration: transitionDuration,
          child: IconButton(
            iconSize: iconSize,
            onPressed: onPressed,
            color: Colors.white,
            icon: Icon(Icons.download_for_offline_outlined),
          ),
        ),
        AnimatedOpacity(
          opacity: isFetching ? 1 : 0,
          curve: Curves.ease,
          duration: transitionDuration,
          child: SpinKitDoubleBounce(
            size: iconSize ?? 24,
            color: Colors.white,
            duration: const Duration(seconds: 3),
          ),
        ),
        AnimatedOpacity(
          opacity: isDownloading ? 1 : 0,
          curve: Curves.ease,
          duration: transitionDuration,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                iconSize: iconSize,
                onPressed: onPressed,
                icon: SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    value: downloadProgress,
                    color: Colors.blue.shade300,
                    strokeWidth: 3,
                  ),
                ),
              ),
              Icon(Icons.stop, size: 16, color: Colors.blue.shade300),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: isDownloaded ? 1 : 0,
          duration: transitionDuration,
          curve: Curves.ease,
          child: IconButton(
            onPressed: onPressed,
            color: Colors.green.shade400,
            icon: Icon(Icons.check_circle_rounded),
            iconSize: iconSize,
          ),
        ),
      ],
    );
  }
}
