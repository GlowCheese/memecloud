import 'package:flutter/material.dart';

enum DownloadStatus { notDownloaded, fetchingDownload, downloading, downloaded }

class DownloadButton extends StatelessWidget {
  final DownloadStatus status;
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

  bool get isDownloaded => status == DownloadStatus.downloaded;
  bool get isDownloading => status == DownloadStatus.downloading;
  bool get isFetching => status == DownloadStatus.fetchingDownload;
  bool get isNotDownloaded => status == DownloadStatus.notDownloaded;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: isNotDownloaded ? 1 : 0,
          curve: Curves.ease,
          duration: transitionDuration,
          child: IconButton(
            iconSize: iconSize,
            onPressed: onPressed,
            icon: Icon(Icons.download_for_offline_outlined),
          ),
        ),
        AnimatedOpacity(
          opacity: isDownloading || isFetching ? 1 : 0,
          curve: Curves.ease,
          duration: transitionDuration,
          child: IconButton(
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
        ),
        AnimatedOpacity(
          opacity: isDownloaded ? 1 : 0,
          duration: transitionDuration,
          curve: Curves.ease,
          child: IconButton(
            onPressed: onPressed,
            color: Colors.green,
            icon: Icon(Icons.check_circle_rounded),
            iconSize: iconSize,
          ),
        ),
      ],
    );
  }
}
