import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadScreen extends StatelessWidget {
  final String storagePath;
  const DownloadScreen({super.key, this.storagePath = 'Android/data/com.kingsng.roleplay/'});

  void _openModpack() async {
    final uri = Uri.parse('https://www.mediafire.com/file/ud0b1qrka3h8rvn/');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020A02),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('MODPACK', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E676).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(Icons.download_rounded, size: 50, color: Color(0xFF00E676)),
            ),
            const SizedBox(height: 30),
            const Text('Game Files Required', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text('Download and install the Kings Nigeria modpack to play. Extract and place files in the correct folder using MT Manager.',
              style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Installation Steps:', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('1. Download the modpack below', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Text('2. Open MT Manager', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Text('3. Extract the zip file', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('4. Move files to $storagePath', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const Text('5. Open app and press PLAY', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  const Text('Note: On newer Android versions, Android/data may be hidden by default. Use MT Manager or a file browser that shows hidden app folders.',
                    style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _openModpack,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF00E676)]),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.3), blurRadius: 15)],
                ),
                child: const Center(
                  child: Text('DOWNLOAD MODPACK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
