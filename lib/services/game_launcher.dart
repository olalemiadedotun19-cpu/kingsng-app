import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:path_provider/path_provider.dart';

class GameLauncher {
  // SA-MP app package info
  static const String sampPackageName = 'ro.alyn_sampmobile.game';
  static const String filesFolder = 'files';
  static const String cleoZip = 'cleo.zip';
  
  // Server connection info - LetMeHost server
  static const String serverIP = '51.38.205.167';
  static const String serverPort = '29291';
  static const String serverAddress = '$serverIP:$serverPort';

  static const String defaultStoragePath = '/storage/emulated/0/Android/data/$sampPackageName';

  /// Get SA-MP game data path (where game files should be placed)
  static Future<String> getGameDataPath() async {
    if (!Platform.isAndroid) return '';

    try {
      final dir = await getExternalStorageDirectory();
      if (dir != null) {
        final path = dir.path;
        final index = path.indexOf('Android/data');
        if (index != -1) {
          final sampPath = '${path.substring(0, index)}Android/data/$sampPackageName';
          final sampDir = Directory(sampPath);
          if (!await sampDir.exists()) {
            await sampDir.create(recursive: true);
          }
          return sampPath;
        }
      }
    } catch (_) {}
    
    return defaultStoragePath;
  }

  /// Check if both required files exist in SA-MP folder
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

  /// Launch SA-MP with auto-connect to LetMeHost server
  static Future<bool> launchSAMP() async {
    if (!Platform.isAndroid) return false;

    try {
      final filesExist = await validateGameFiles();
      if (!filesExist) {
        return false;
      }

      // Launch SA-MP with server connection intent
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: sampPackageName,
        componentName: '$sampPackageName/$sampPackageName.MainActivity',
        flags: <int>[0x10000000],
        arguments: <String, dynamic>{
          'connect_to': serverAddress,
          'server': serverIP,
          'port': int.parse(serverPort),
        },
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

    return '✗ Missing: ${missing.join(', ')}. Download and extract the modpack to: Android/data/$sampPackageName/';
  }
}
