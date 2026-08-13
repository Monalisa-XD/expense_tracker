import 'dart:isolate';
import 'dart:io';

void main() async {
  final uri = Uri.parse('package:local_auth/src/local_auth.dart');
  final fileUri = await Isolate.resolvePackageUri(uri);
  if (fileUri != null) {
    final path = fileUri.toFilePath();
    print('Path: $path');
    final content = File(path).readAsStringSync();
    print(content);
  }
}
