import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class FileStorageService {
  Future<File> saveFileLocally(File sourceFile, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final savedFile = File('${appDir.path}/attachments/$fileName');

    // Ensure attachments folder exists
    await savedFile.parent.create(recursive: true);
    return sourceFile.copy(savedFile.path);
  }
}
