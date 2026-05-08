import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:path_provider/path_provider.dart';

class GameLauncher {
  static const String packageName = 'com.kingsng.kingsng_roleplay';
  static const String filesFolder = 'files';
  static const String cleoZip = 'cleo.zip';

  static const String defaultStoragePath = '/storage/emulated/0/Android/data/$packageName';

  static Future<String> _resolvedExternalRoot() async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) return '';

    final path = dir.path;
    final index = path.indexOf('Android/data');
    if (index != -1) {
      return path.substring(0, index);
    }

    return path;
  }

  /// Get the app data directory path and create it if missing
  static Future<String> getGameDataPath() async {
    if (!Platform.isAndroid) return '';

    try {
      var rootPath = await _resolvedExternalRoot();
      if (rootPath.isEmpty) {
        rootPath = '/storage/emulated/0';
      }

      final packageDir = Directory('$rootPath/Android/data/$packageName');
      if (!await packageDir.exists()) {
        await packageDir.create(recursive: true);
      }

      final requiredFilesDir = Directory('${packageDir.path}/$filesFolder');
      if (!await requiredFilesDir.exists()) {
        await requiredFilesDir.create(recursive: true);
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

      final filesFolderPath = '$gameDataPath/$filesFolder';
      final cleoFilePath = '$gameDataPath/$cleoZip';
      
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
      
      final filesFolderPath = '$gameDataPath/$filesFolder';
      final cleoFilePath = '$gameDataPath/$cleoZip';
      
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
  /// Launch SA-MP game with proper validation
  static Future<bool> launchSAMP() async {
    if (!Platform.isAndroid) return false;

    try {
      final filesExist = await validateGameFiles();
      if (!filesExist) {
        return false;
      }

      const intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: 'ro.alyn_sampmobile.game',
        componentName: 'ro.alyn_sampmobile.game/ro.alyn_sampmobile.game.MainActivity',
        flags: <int>[0x10000000],
      );
      await intent.launch();
      return true;
    } catch (e) {
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

    final missing = <String>[];
    if (!filesOk) missing.add('"files" folder');
    if (!cleoOk) missing.add('"cleo.zip"');

    return '✗ Missing: ${missing.join(', ')}. Download and extract the modpack.';
  }
}
