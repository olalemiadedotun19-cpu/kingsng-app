import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const KingsNGApp());
}

class KingsNGApp extends StatelessWidget {
  const KingsNGApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kings Nigeria RP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF00C853),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
