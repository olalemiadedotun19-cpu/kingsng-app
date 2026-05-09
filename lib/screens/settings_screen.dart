import 'package:flutter/material.dart';

import '../services/game_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final String storagePath;
  const SettingsScreen({super.key, String? storagePath}) : storagePath = storagePath ?? GameLauncher.defaultStoragePath;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _diagnostics = {};

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    final diagnostics = await GameLauncher.runDiagnostics();
    setState(() {
      _diagnostics = diagnostics;
    });
  }

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
        children: [
          const _Tile(icon: Icons.dns, title: 'Server', subtitle: '51.38.205.167:29291'),
          const _Tile(icon: Icons.language, title: 'Website', subtitle: 'kingsng.netlify.app'),
          const _Tile(icon: Icons.info_outline, title: 'Version', subtitle: 'Kings Nigeria RP v1.0'),
          _Tile(icon: Icons.folder_open, title: 'Game Files Path', subtitle: _diagnostics['gameDataPath'] ?? widget.storagePath),
          _Tile(icon: Icons.download_done, title: 'SA-MP Installed', subtitle: (_diagnostics['sampInstalled'] ?? false) ? 'Yes' : 'No'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.health_and_safety, color: Color(0xFF00E676), size: 22),
                    const SizedBox(width: 16),
                    const Text('System Diagnostics', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white38, size: 18),
                      onPressed: _runDiagnostics,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDiagnosticItem('Permissions', _diagnostics['permissionsGranted'] ?? false),
                _buildDiagnosticItem('Internet', _diagnostics['networkAvailable'] ?? false),
                _buildDiagnosticItem('Game Files', _diagnostics['filesValid'] ?? false),
                _buildDiagnosticItem('Server Online', _diagnostics['serverOnline'] ?? false),
                _buildDiagnosticItem('SA-MP Installed', _diagnostics['sampInstalled'] ?? false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticItem(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
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
