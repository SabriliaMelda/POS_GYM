import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web: buat blob lalu klik anchor tersembunyi agar browser mengunduh file.
Future<void> downloadReportFile({
  required List<int> bytes,
  required String filename,
  required String mimeType,
}) async {
  final data = Uint8List.fromList(bytes).toJS;
  final blob = web.Blob(
    <JSUint8Array>[data].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor =
      web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = filename
        ..style.display = 'none';
  web.document.body!.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
