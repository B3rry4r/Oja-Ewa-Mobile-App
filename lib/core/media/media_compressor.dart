import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Centralised media compression used before any upload.
///
/// Mirrors what WhatsApp / Telegram / Instagram do: shrink large originals to
/// a sane resolution + quality so we never push raw camera files over the
/// wire, while keeping perceptual quality high.
///
/// Images: longest edge is capped at [_maxEdge] px, re-encoded as JPEG at
/// [_quality]. Aspect ratio is preserved. Files that are already tiny
/// (< [_skipBytes]) are left untouched. On any failure the original path is
/// returned so an upload is never blocked by compression.
///
/// Non-image files (PDFs, etc.) are returned unchanged.
class MediaCompressor {
  const MediaCompressor._();

  static const int _maxEdge = 1600;
  static const int _quality = 80;

  /// Skip compression for files smaller than this (~100 KB). Re-encoding a
  /// small image rarely helps and can even grow it.
  static const int _skipBytes = 100 * 1024;

  static const Set<String> _imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.heic',
    '.heif',
    '.bmp',
  };

  /// Returns true when [path] looks like a compressible raster image.
  static bool isImagePath(String path) =>
      _imageExtensions.contains(p.extension(path).toLowerCase());

  /// Compress [filePath] if it is an image, returning the path to upload.
  ///
  /// Falls back to the original [filePath] for non-images, tiny files, or any
  /// failure during compression.
  static Future<String> compressForUpload(String filePath) async {
    if (!isImagePath(filePath)) return filePath;

    try {
      final input = File(filePath);
      if (!input.existsSync()) return filePath;

      final length = await input.length();
      if (length > 0 && length < _skipBytes) return filePath;

      final dir = await getTemporaryDirectory();
      final baseName = p.basenameWithoutExtension(filePath);
      final target = p.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}_$baseName.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        target,
        quality: _quality,
        minWidth: _maxEdge,
        minHeight: _maxEdge,
        keepExif: false,
        format: CompressFormat.jpeg,
      );

      if (result == null) return filePath;

      // If compression somehow produced a larger file, keep the original.
      final compressedLength = await File(result.path).length();
      if (compressedLength >= length && length > 0) return filePath;

      return result.path;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('MediaCompressor: falling back to original for "$filePath": $e\n$st');
      }
      return filePath;
    }
  }
}
