import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

ScaffoldMessengerState _showSnackbar(
  BuildContext context, {
  required String message,
  required String title,
  required ContentType contentType,
}) {
  return ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: contentType,
        ),
      ),
    );
}

ScaffoldMessengerState showErrorSnackbar(
  BuildContext context, {
  required String message,
  String title = 'Lỗi!',
}) {
  return _showSnackbar(
    context,
    message: message,
    title: title,
    contentType: ContentType.failure,
  );
}

ScaffoldMessengerState showWarningSnackbar(
  BuildContext context, {
  required String message,
  String title = 'Cảnh báo!',
}) {
  return _showSnackbar(
    context,
    message: message,
    title: title,
    contentType: ContentType.warning,
  );
}

ScaffoldMessengerState showSuccessSnackbar(
  BuildContext context, {
  required String message,
  String title = 'Thành công!',
}) {
  return _showSnackbar(
    context,
    message: message,
    title: title,
    contentType: ContentType.success,
  );
}

ScaffoldMessengerState showInfoSnackbar(
  BuildContext context, {
  required String message,
  String title = 'Info',
}) {
  return _showSnackbar(
    context,
    message: message,
    title: title,
    contentType: ContentType.help,
  );
}
