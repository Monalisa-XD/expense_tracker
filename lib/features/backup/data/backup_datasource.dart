import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

abstract class BackupDataSource {
  Future<void> shareBackupFile(String jsonContent, String filename);
  Future<String?> pickBackupFile();
}

class BackupDataSourceImpl implements BackupDataSource {
  @override
  Future<void> shareBackupFile(String jsonContent, String filename) async {
    final bytes = utf8.encode(jsonContent);
    await Share.shareXFiles(
      [XFile.fromData(bytes, name: filename, mimeType: 'application/json')],
      subject: 'Expense Tracker Backup',
    );
  }

  @override
  Future<String?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.single.bytes != null) {
      return utf8.decode(result.files.single.bytes!);
    }
    // Fallback: if bytes is null (like on mobile), we can read path
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      // We can read file path if on desktop/mobile
      final ioFile = result.files.single.bytes;
      if (ioFile != null) {
        return utf8.decode(ioFile);
      }
    }
    return null;
  }
}
