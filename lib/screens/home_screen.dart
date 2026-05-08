import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/game_launcher.dart';
import 'download_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  String _storagePath = '';
  String _statusMessage = 'Checking game files...';
  bool _filesReady = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _initStoragePath();
  }

  Future<void> _initStoragePath() async {
    if (!Platform.isAndroid) return;

    final path = await GameLauncher.getGameDataPath();
    final ready = await GameLauncher.validateGameFiles();
    final status = await GameLauncher.getStatusMessage();

    setState(() {
      _storagePath = path.isNotEmpty ? path : GameLauncher.defaultStoragePath;
      _filesReady = ready;
      _statusMessage = status;
    });
  }

  Future<void> _launchGame() async {
    final success = await GameLauncher.launchSAMP();
    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_filesReady ? 'Could not launch SA-MP. Make sure it is installed.' : 'Required files are missing. Install the modpack first.')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Launching SA-MP...')),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link. Please try again.')),
      );
    }
  }

  Future<void> _openGameFolder() async {
    if (!Platform.isAndroid) return;

    var path = _storagePath;
    if (path.isEmpty) {
      path = await GameLauncher.getGameDataPath();
    }

    if (path.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not locate the game folder.')),
      );
      return;
    }

    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: Uri.file(path).toString(),
      flags: <int>[0x10000000],
    );

    try {
      await intent.launch();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open folder. Please use a file manager.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020A02),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            return isLandscape ? _buildLandscape(context) : _buildPortrait(context);
          },
        ),
      ),
    );
  }

  Widget _buildPortrait(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF00E676), size: 8),
                    SizedBox(width: 6),
                    Text('SERVER ONLINE', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(storagePath: _storagePath))),
                icon: const Icon(Icons.settings_outlined, color: Colors.white54),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Icon(Icons.emoji_events, size: 90, color: Color.fromRGBO(0, 230, 118, _pulseAnim.value)),
              ),
              const SizedBox(height: 20),
              const Text('KINGS', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 10)),
              Container(width: 200, height: 2, margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Color(0xFF00E676), Colors.transparent]))),
              const Text('N I G E R I A  R P', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF00E676), letterSpacing: 5)),
              const SizedBox(height: 6),
              const Text("Nigeria's #1 Roleplay Server", style: TextStyle(fontSize: 13, color: Colors.white38)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) => Icon(Icons.circle, size: 12, color: _filesReady ? Colors.greenAccent : Colors.orangeAccent.withValues(alpha: _pulseAnim.value)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: _filesReady ? _launchGame : () => Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadScreen(storagePath: _storagePath))),
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) => Container(
                      width: 220, height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _filesReady ? [const Color(0xFF00C853), const Color(0xFF00E676)] : [const Color(0xFF3E2723), const Color(0xFFD84315)]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 230, 118, _pulseAnim.value * 0.5), blurRadius: 20, spreadRadius: 2)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_filesReady ? Icons.play_arrow_rounded : Icons.download_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            _filesReady ? 'PLAY NOW' : 'GET MODPACK',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('51.38.205.167:29291', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _Btn(icon: Icons.language, label: 'Website', onTap: () => _openUrl('https://kingsng.netlify.app'))),
                  const SizedBox(width: 12),
                  Expanded(child: _Btn(icon: Icons.discord, label: 'Discord', onTap: () => _openUrl('https://discord.gg/kingsng'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _Btn(icon: Icons.gavel, label: 'Rules', onTap: () => _openUrl('https://kingsng.netlify.app/rules'))),
                  const SizedBox(width: 12),
                  Expanded(child: _Btn(icon: Icons.folder_open, label: 'Open Folder', onTap: _openGameFolder)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _Btn(icon: Icons.download_rounded, label: 'Modpack', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadScreen(storagePath: _storagePath))))),
                  const SizedBox(width: 12),
                  Expanded(child: _Btn(icon: Icons.play_arrow_rounded, label: _filesReady ? 'Play Now' : 'Get Modpack', onTap: _filesReady ? _launchGame : () => Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadScreen(storagePath: _storagePath))))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFF00E676), size: 8),
                          SizedBox(width: 6),
                          Text('SERVER ONLINE', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(storagePath: _storagePath))),
                      icon: const Icon(Icons.settings_outlined, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) => Icon(Icons.emoji_events, size: 110, color: Color.fromRGBO(0, 230, 118, _pulseAnim.value)),
                ),
                const SizedBox(height: 24),
                const Text('KINGS', style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 12)),
                Container(width: 260, height: 2, margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Color(0xFF00E676), Colors.transparent]))),
                const Text('N I G E R I A  R P', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF00E676), letterSpacing: 6)),
                const SizedBox(height: 10),
                const Text("Nigeria's #1 Roleplay Server", style: TextStyle(fontSize: 14, color: Colors.white38)),
                const SizedBox(height: 32),
                Text('App folder:', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text(
                  _storagePath.isNotEmpty ? _storagePath : GameLauncher.defaultStoragePath,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        Container(width: 1, color: Colors.white12),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Btn(icon: Icons.language, label: 'Website', onTap: () => _openUrl('https://kingsng.netlify.app')),
                const SizedBox(height: 16),
                _Btn(icon: Icons.discord, label: 'Discord', onTap: () => _openUrl('https://discord.gg/kingsng')),
                const SizedBox(height: 16),
                _Btn(icon: Icons.gavel, label: 'Rules', onTap: () => _openUrl('https://kingsng.netlify.app/rules')),
                const SizedBox(height: 16),
                _Btn(icon: Icons.folder_open, label: 'Open Folder', onTap: _openGameFolder),
                const SizedBox(height: 16),
                _Btn(icon: Icons.download_rounded, label: 'Modpack', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadScreen(storagePath: _storagePath)))),
                const SizedBox(height: 16),
                _Btn(
                  icon: Icons.play_arrow_rounded,
                  label: _filesReady ? 'Play Now' : 'Get Modpack',
                  onTap: _filesReady ? _launchGame : () => Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadScreen(storagePath: _storagePath))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF00E676), size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
