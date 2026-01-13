import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<PlatformFile?> pickSingleFile({List<String>? allowedExtensions}) async {
    final res = await FilePicker.platform.pickFiles(
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: false,
    );

    if (res == null || res.files.isEmpty) return null;
    return res.files.first;
  }
}
