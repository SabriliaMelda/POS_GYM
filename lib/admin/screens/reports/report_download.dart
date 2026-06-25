// Memicu unduhan file laporan.
//
// - Di web: membuat blob lalu klik anchor agar browser mengunduh file.
// - Di native (Android/iOS/desktop): memakai share sheet.
//
// Implementasi dipilih otomatis lewat conditional import.
export 'report_download_io.dart'
    if (dart.library.js_interop) 'report_download_web.dart';
