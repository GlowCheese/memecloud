import 'package:memecloud/blocs/dl_status/dl_status_enum.dart';

class DlStatusState {
  final DlStatus status;
  DlStatusState(this.status);
}

class NotDownloadedState extends DlStatusState {
  NotDownloadedState() : super(DlStatus.notDownloaded);
}

class FetchingDownloadState extends DlStatusState {
  FetchingDownloadState() : super(DlStatus.fetchingDownload);
}

class DownloadingState extends DlStatusState {
  double downloadProgress;
  DownloadingState(this.downloadProgress) : super(DlStatus.downloading);
}

class DownloadedState extends DlStatusState {
  DownloadedState() : super(DlStatus.downloaded);
}
