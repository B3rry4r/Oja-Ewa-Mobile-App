import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'file_picker_service.dart';

final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return FilePickerService();
});
