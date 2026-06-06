import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../media/media_compressor.dart';

/// Create a MultipartFile from a local path.
MultipartFile multipartFromPath(String filePath) {
  return MultipartFile.fromFileSync(
    filePath,
    filename: p.basename(filePath),
  );
}

/// Create a MultipartFile from a local path, compressing images first
/// (WhatsApp/Telegram-style) so we never upload raw originals. Non-image
/// files and compression failures fall back to the original bytes.
Future<MultipartFile> multipartFromPathCompressed(String filePath) async {
  final uploadPath = await MediaCompressor.compressForUpload(filePath);
  return MultipartFile.fromFileSync(
    uploadPath,
    // Keep the user-facing filename based on the original selection.
    filename: p.basename(filePath),
  );
}
