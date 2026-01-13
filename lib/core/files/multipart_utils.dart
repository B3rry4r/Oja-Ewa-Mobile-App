import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

/// Create a MultipartFile from a local path.
MultipartFile multipartFromPath(String filePath) {
  return MultipartFile.fromFileSync(
    filePath,
    filename: p.basename(filePath),
  );
}
