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
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: isLandscape ? _buildLandscape(context, constraints) : _buildPortrait(context, constraints),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortrait(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final compact = height < 720;
    final iconSize = compact ? 72.0 : 90.0;
    final titleSize = compact ? 46.0 : 56.0;
    final subtitleSize = compact ? 12.0 : 13.0;
    final infoFont = compact ? 12.0 : 13.0;
    final buttonHeight = compact ? 52.0 : 60.0;
    final buttonFont = compact ? 16.0 : 18.0;
    final buttonWidth = width < 360 ? width - 40 : (width - 56) / 2;
    final mainButtonWidth = width < 360 ? width - 80 : 220.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
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
                builder: (context, child) => Icon(Icons.emoji_events, size: iconSize, color: Color.fromRGBO(0, 230, 118, _pulseAnim.value)),
              ),
              SizedBox(height: compact ? 14 : 20),
              Text('KINGS', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 10)),
              Container(width: width * 0.55, height: 2, margin: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Color(0xFF00E676), Colors.transparent]))),
              Text('N I G E R I A  R P', style: TextStyle(fontSize: compact ? 14 : 16, fontWeight: FontWeight.w600, color: const Color(0xFF00E676), letterSpacing: 5)),
              const SizedBox(height: 6),
              Text("Nigeria's #1 Roleplay Server", style: TextStyle(fontSize: subtitleSize, color: Colors.white38)),
              SizedBox(height: compact ? 14 : 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: compact ? 12 : 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(color: Colors.white70, fontSize: infoFont, height: 1.4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) => Icon(Icons.circle, size: 12, color: _filesReady ? Colors.greenAccent : Colors.orangeAccent.withValues(alpha: _pulseAnim.value)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 14 : 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: _filesReady ? _launchGame : () => Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadScreen(storagePath: _storagePath))),
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) => Container(
                      width: mainButtonWidth,
                      height: buttonHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _filesReady ? [const Color(0xFF00C853), const Color(0xFF00E676)] : [const Color(0xFF3E2723), const Color(0xFFD84315)]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 230, 118, _pulseAnim.value * 0.5), blurRadius: 20, spreadRadius: 2)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_filesReady ? Icons.play_arrow_rounded : Icons.download_rounded, color: Colors.white, size: compact ? 24 : 28),
                          const SizedBox(width: 8),
                          Text(
                            _filesReady ? 'PLAY NOW' : 'GET MODPACK',
                            style: TextStyle(color: Colors.white, fontSize: buttonFont, fontWeight: FontWeight.w800, letterSpacing: 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('51.38.205.167:29291', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: infoFont)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(width: buttonWidth, child: _Btn(icon: Icons.language, label: 'Website', onTap: () => _openUrl('https://kingsng.netlify.app'))),
              SizedBox(width: buttonWidth, child: _Btn(icon: Icons.discord, label: 'Discord', onTap: () => _openUrl('https://discord.gg/kingsng'))),
              SizedBox(width: buttonWidth, child: _Btn(icon: Icons.gavel, label: 'Rules', onTap: () => _openUrl('https://kingsng.netlify.app/rules'))),
              SizedBox(width: buttonWidth, child: _Btn(icon: Icons.folder_open, label: 'Open Folder', onTap: _openGameFolder)),
              SizedBox(width: buttonWidth, child: _Btn(icon: Icons.download_rounded, label: 'Modpack', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadScreen(storagePath: _storagePath))))),
              SizedBox(width: buttonWidth, child: _Btn(icon: Icons.play_arrow_rounded, label: _filesReady ? 'Play Now' : 'Get Modpack', onTap: _filesReady ? _launchGame : () => Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadScreen(storagePath: _storagePath))))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final compact = height < 600 || width < 900;
    final iconSize = compact ? 90.0 : 110.0;
    final titleSize = compact ? 54.0 : 72.0;
    final buttonSpacing = compact ? 10.0 : 14.0;
    final buttonHeight = compact ? 50.0 : 56.0;
    final buttonWidth = width / 2.5;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24, vertical: compact ? 12 : 16),
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
                SizedBox(height: compact ? 22 : 32),
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) => Icon(Icons.emoji_events, size: iconSize, color: Color.fromRGBO(0, 230, 118, _pulseAnim.value)),
                ),
                SizedBox(height: compact ? 18 : 24),
                Text('KINGS', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 10)),
                Container(width: width * 0.35, height: 2, margin: EdgeInsets.symmetric(vertical: compact ? 8 : 12),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Color(0xFF00E676), Colors.transparent]))),
                Text('N I G E R I A  R P', style: TextStyle(fontSize: compact ? 16 : 18, fontWeight: FontWeight.w600, color: const Color(0xFF00E676), letterSpacing: 6)),
                SizedBox(height: compact ? 8 : 10),
                const Text("Nigeria's #1 Roleplay Server", style: TextStyle(fontSize: 14, color: Colors.white38)),
                SizedBox(height: compact ? 18 : 28),
                Text('App folder:', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: compact ? 11 : 12, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text(
                  _storagePath.isNotEmpty ? _storagePath : GameLauncher.defaultStoragePath,
                  style: TextStyle(color: Colors.white70, fontSize: compact ? 11 : 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        Container(width: 1, color: Colors.white12),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24, vertical: compact ? 12 : 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: buttonWidth, height: buttonHeight, child: _Btn(icon: Icons.language, label: 'Website', onTap: () => _openUrl('https://kingsng.netlify.app'))),
                SizedBox(height: buttonSpacing),
                SizedBox(width: buttonWidth, height: buttonHeight, child: _Btn(icon: Icons.discord, label: 'Discord', onTap: () => _openUrl('https://discord.gg/kingsng'))),
                SizedBox(height: buttonSpacing),
                SizedBox(width: buttonWidth, height: buttonHeight, child: _Btn(icon: Icons.gavel, label: 'Rules', onTap: () => _openUrl('https://kingsng.netlify.app/rules'))),
                SizedBox(height: buttonSpacing),
                SizedBox(width: buttonWidth, height: buttonHeight, child: _Btn(icon: Icons.folder_open, label: 'Open Folder', onTap: _openGameFolder)),
                SizedBox(height: buttonSpacing),
                SizedBox(width: buttonWidth, height: buttonHeight, child: _Btn(icon: Icons.download_rounded, label: 'Modpack', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadScreen(storagePath: _storagePath))))),
                SizedBox(height: buttonSpacing),
                SizedBox(width: buttonWidth, height: buttonHeight, child: _Btn(
                  icon: Icons.play_arrow_rounded,
                  label: _filesReady ? 'Play Now' : 'Get Modpack',
                  onTap: _filesReady ? _launchGame : () => Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadScreen(storagePath: _storagePath))),
                )),
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
