import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Native (Android/iOS/desktop): bagikan file lewat share sheet.
Future<void> downloadReportFile({
  required List<int> bytes,
  required String filename,
  required String mimeType,
}) async {
  await Share.shareXFiles([
    XFile.fromData(
      Uint8List.fromList(bytes),
      mimeType: mimeType,
      name: filename,
    ),
  ]);
}
