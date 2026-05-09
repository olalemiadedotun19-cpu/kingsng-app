import 'dart:io';
import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Alternative SA-MP package names for different builds
  static const List<String> sampPackageVariants = [
    'ro.alyn_sampmobile.game',        // Official SA-MP
    'com.gtaindian.samp',              // Alternative build
    'com.igrosoft.samp',               // Another variant
  ];

  /// Request all necessary permissions for SA-MP launching
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // Try MANAGE_EXTERNAL_STORAGE first (Android 11+)
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    // Fallback to regular storage permission
    if (await Permission.storage.isGranted) {
      return true;
    }

    // Request MANAGE_EXTERNAL_STORAGE
    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) {
      return true;
    }

    // Request regular storage permission
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  /// Request all permissions needed for the launcher
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.manageExternalStorage,
    ];

    return await permissions.request();
  }

  /// Check if all required permissions are granted
  static Future<bool> hasAllPermissions() async {
    final results = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    return results.values.every((status) => status.isGranted);
  }

  /// Check if device has internet connectivity
  static Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Test if SA-MP server is reachable
  static Future<bool> isServerOnline() async {
    try {
      final socket = await Socket.connect(
        serverIP,
        int.parse(serverPort),
        timeout: const Duration(seconds: 5)
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get SA-MP game data path (where game files should be placed)
  static Future<String> getGameDataPath() async {
    if (!Platform.isAndroid) return '';

    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      return defaultStoragePath;
    }

    try {
      final dir = await getExternalStorageDirectory();
      if (dir != null) {
        final path = dir.path;
        final index = path.indexOf('Android/data');
        if (index != -1) {
          final root = path.substring(0, index);

          for (final variant in sampPackageVariants) {
            final variantPath = '$root/Android/data/$variant';
            final variantDir = Directory(variantPath);
            if (await variantDir.exists()) {
              return variantPath;
            }
          }

          // No existing SA-MP folder found. Return default official package path.
          final defaultPath = '$root/Android/data/$sampPackageName';
          final defaultDir = Directory(defaultPath);
          if (!await defaultDir.exists()) {
            await defaultDir.create(recursive: true);
          }
          return defaultPath;
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

  /// Launch SA-MP game and auto-connect to the server with comprehensive error handling
  static Future<LaunchResult> launchSAMP() async {
    if (!Platform.isAndroid) {
      return LaunchResult(success: false, error: 'Not running on Android');
    }

    // Step 1: Check permissions
    final hasPermissions = await hasAllPermissions();
    if (!hasPermissions) {
      return LaunchResult(success: false, error: 'Storage permissions required');
    }

    // Step 2: Check network connectivity
    final hasNetwork = await isNetworkAvailable();
    if (!hasNetwork) {
      return LaunchResult(success: false, error: 'No internet connection');
    }

    // Step 3: Validate game files
    final filesValid = await validateGameFiles();
    if (!filesValid) {
      return LaunchResult(success: false, error: 'Game files not found or invalid');
    }

    // Step 4: Test server connectivity
    final serverOnline = await isServerOnline();
    if (!serverOnline) {
      return LaunchResult(success: false, error: 'Server unreachable');
    }

    // Step 5: Try to launch with different package variants
    for (final packageName in sampPackageVariants) {
      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'samp://$serverAddress',
          package: packageName,
          flags: <int>[0x10000000], // FLAG_ACTIVITY_NEW_TASK
        );
        await intent.launch();

        // Save successful server to recent list
        await _saveRecentServer(serverIP, int.parse(serverPort));

        return LaunchResult(success: true);
      } catch (e) {
        continue; // Try next package variant
      }
    }

    return LaunchResult(success: false, error: 'SA-MP app not installed');
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

  /// Save server to recent servers list
  static Future<void> _saveRecentServer(String ip, int port) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('recent_servers') ?? [];

      final serverEntry = '$ip:$port';
      history.removeWhere((s) => s == serverEntry);
      history.insert(0, serverEntry);

      if (history.length > 10) history.removeLast();

      await prefs.setStringList('recent_servers', history);
    } catch (_) {
      // Ignore errors in saving recent servers
    }
  }

  /// Comprehensive diagnostic check
  static Future<Map<String, dynamic>> runDiagnostics() async {
    return {
      'permissionsGranted': await hasAllPermissions(),
      'networkAvailable': await isNetworkAvailable(),
      'filesValid': await validateGameFiles(),
      'serverOnline': await isServerOnline(),
      'sampInstalled': await isSAMPInstalled(),
      'gameDataPath': await getGameDataPath(),
    };
  }

  /// Check if SA-MP app is installed
  static Future<bool> isSAMPInstalled() async {
    if (!Platform.isAndroid) return false;

    // Try different package variants
    for (final packageName in sampPackageVariants) {
      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'samp://$serverAddress',
          package: packageName,
        );
        // This will throw if package doesn't exist
        await intent.launch();
        return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }
}

/// Result class for launch operations
class LaunchResult {
  final bool success;
  final String? error;

  LaunchResult({required this.success, this.error});

  @override
  String toString() => success ? 'Success' : 'Failed: $error';
}
