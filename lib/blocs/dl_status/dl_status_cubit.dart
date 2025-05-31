import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/blocs/dl_status/dl_status_state.dart';

class DlStatusCubit extends Cubit<DlStatusState> {
  DlStatusCubit(super.initialState);
  CancelableOperation<bool>? downloadTask;

  void update(DlStatusState status, {CancelableOperation<bool>? downloadTask}) {
    if (downloadTask != null) this.downloadTask = downloadTask;
    if (status is! DownloadingState) this.downloadTask = null;
    emit(status);
  }

  void updateProgress(double downloadProgress) {
    emit(DownloadingState(downloadProgress));
  }

  Future<void> updateCancel() async {
    if (downloadTask != null) {
      await downloadTask!.cancel();
      downloadTask = null;
    }
    emit(NotDownloadedState());
  }
}
