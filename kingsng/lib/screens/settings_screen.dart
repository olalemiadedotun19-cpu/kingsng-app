import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020A02),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('SETTINGS', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _Tile(icon: Icons.dns, title: 'Server', subtitle: '51.38.205.167:29291'),
          _Tile(icon: Icons.language, title: 'Website', subtitle: 'kingsng.netlify.app'),
          _Tile(icon: Icons.info_outline, title: 'Version', subtitle: 'Kings Nigeria RP v1.0'),
          _Tile(icon: Icons.folder_outlined, title: 'Game Files', subtitle: 'Android/data/ro.alyn_sampmobile.game/'),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Tile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E676), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
