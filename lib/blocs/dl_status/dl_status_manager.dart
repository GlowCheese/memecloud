import 'package:async/async.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/blocs/dl_status/dl_status_cubit.dart';
import 'package:memecloud/blocs/dl_status/dl_status_state.dart';

class DlStatusManager {
  Map<String, DlStatusCubit> songDlStatusCubitMap = {};

  DlStatusCubit getCubit(String songId) {
    return songDlStatusCubitMap[songId] ??= DlStatusCubit(
      getIt<ApiKit>().isSongDownloaded(songId)
          ? DownloadedState()
          : NotDownloadedState(),
    );
  }

  void update(
    String songId, {
    bool isFetching = false,
    bool isCompleted = false,
    CancelableOperation<bool>? downloadTask,
  }) {
    final cubit = songDlStatusCubitMap[songId];

    if (isCompleted) {
      cubit?.update(DownloadedState());
    } else if (isFetching) {
      cubit?.update(FetchingDownloadState());
    } else if (downloadTask != null) {
      cubit?.update(DownloadingState(0), downloadTask: downloadTask);
    }
  }

  void updateProgress(String songId, double downloadProgress) {
    songDlStatusCubitMap[songId]?.updateProgress(downloadProgress);
  }

  Future<void> updateCancel(String songId) async {
    songDlStatusCubitMap[songId]?.updateCancel();
  }
}
