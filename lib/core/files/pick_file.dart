import 'package:file_picker/file_picker.dart';

/// Small helper for picking a single file and returning its local path.
Future<String?> pickSingleFilePath() async {
  final res = await FilePicker.platform.pickFiles(withData: false);
  if (res == null || res.files.isEmpty) return null;
  return res.files.first.path;
}
