import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  /// Saves ONLY image files under /attachments/images in app storage.
  /// Throws if file is not an allowed image format.
  Future<File> saveImageLocally(File sourceFile) async {
    final ext = path.extension(sourceFile.path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png', '.gif'].contains(ext)) {
      throw Exception('Unsupported image format: $ext');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/attachments/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = path.basename(sourceFile.path);
    final savedPath = path.join(imagesDir.path, fileName);
    return sourceFile.copy(savedPath);
  }
}
