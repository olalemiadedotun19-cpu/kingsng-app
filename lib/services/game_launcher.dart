import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GameLauncher {
  static const String filesFolder = 'files';
  static const String cleoZip = 'cleo.zip';

  /// Get the app data directory path
  static Future<String> getGameDataPath() async {
    if (!Platform.isAndroid) return '';
    
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return '';
      
      final packageDir = Directory('${dir.parent.parent.path}/com.kingsng.roleplay');
      if (!await packageDir.exists()) {
        await packageDir.create(recursive: true);
      }
      
      return packageDir.path;
    } catch (_) {
      return '';
    }
  }

  /// Check if both required files exist
  static Future<bool> validateGameFiles() async {
    try {
      final gameDataPath = await getGameDataPath();
      if (gameDataPath.isEmpty) return false;

      final filesFolderPath = '$gameDataPath/files';
      final cleoFilePath = '$gameDataPath/cleo.zip';
      
      final filesDir = Directory(filesFolderPath);
      final cleoFile = File(cleoFilePath);

      final filesFolderExists = await filesDir.exists();
      final cleoFileExists = await cleoFile.exists();

      return filesFolderExists && cleoFileExists;
    } catch (_) {
      return false;
    }
  }

  /// Get status of required files
  static Future<Map<String, bool>> getFileStatus() async {
    try {
      final gameDataPath = await getGameDataPath();
      
      final filesFolderPath = '$gameDataPath/files';
      final cleoFilePath = '$gameDataPath/cleo.zip';
      
      final filesDir = Directory(filesFolderPath);
      final cleoFile = File(cleoFilePath);

      return {
        'filesFolder': await filesDir.exists(),
        'cleoZip': await cleoFile.exists(),
      };
    } catch (_) {
      return {
        'filesFolder': false,
        'cleoZip': false,
      };
    }
  }

  /// Launch SA-MP game
  static Future<bool> launchSAMP() async {
    if (!Platform.isAndroid) return false;

    try {
      // Check if files exist first
      final filesExist = await validateGameFiles();
      if (!filesExist) {
        throw Exception('Required game files not found');
      }

      // Try to launch SA-MP using Android Intent
      final result = await Process.run('am', [
        'start',
        '-n',
        'ro.alyn_sampmobile.game/ro.alyn_sampmobile.game.MainActivity',
      ]);

      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Get human-readable file status message
  static Future<String> getStatusMessage() async {
    final status = await getFileStatus();
    final filesOk = status['filesFolder'] ?? false;
    final cleoOk = status['cleoZip'] ?? false;

    if (filesOk && cleoOk) {
      return '✓ All game files detected. Ready to play!';
    }

    final missing = [];
    if (!filesOk) missing.add('"files" folder');
    if (!cleoOk) missing.add('"cleo.zip"');

    return '✗ Missing: ${missing.join(', ')}. Download and extract the modpack.';
  }
}
