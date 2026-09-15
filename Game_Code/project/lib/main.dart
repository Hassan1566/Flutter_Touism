import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/how_to_play_screen.dart';
import 'screens/player_profile_screen.dart';
import 'screens/player_setup_screen.dart';
import 'screens/settings_screen.dart';
import 'services/music_service.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const MintedApp());
}

class MintedApp extends StatelessWidget {
  const MintedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MINTED',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D3B1E), Color(0xFF1B5E20)],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 86, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'MINTED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Build Wealth. Make Smart Decisions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 42),
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _musicEnabled = true;
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _loadHomeState();
  }

  Future<void> _loadHomeState() async {
    final music = await MusicService.isEnabled();
    final saved = await StorageService.hasSavedGame();

    if (!mounted) return;

    setState(() {
      _musicEnabled = music;
      _hasSavedGame = saved;
    });
  }

  Future<void> _toggleMusic() async {
    final value = !_musicEnabled;

    setState(() {
      _musicEnabled = value;
    });

    await MusicService.setEnabled(value);
  }

  Future<void> _continueGame() async {
    final savedGame = await StorageService.loadGame();

    if (!mounted) return;

    if (savedGame == null || savedGame.players.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No saved game found.')));
      return;
    }

    if (savedGame.isGameFinished) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The saved game is already finished.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerProfileScreen(gameState: savedGame),
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    _loadHomeState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'MINTED',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Build Wealth. Make Smart Decisions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlayerSetupScreen(),
                      ),
                    ).then((_) => _loadHomeState());
                  },
                  child: const Text(
                    'START GAME',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed: _hasSavedGame ? _continueGame : null,
                  child: Text(
                    _hasSavedGame ? 'CONTINUE GAME' : 'NO SAVED GAME',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HowToPlayScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'HOW TO PLAY',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton.icon(
                  onPressed: _toggleMusic,
                  icon: Icon(
                    _musicEnabled ? Icons.music_note : Icons.music_off,
                  ),
                  label: Text(
                    _musicEnabled ? 'MUSIC ON' : 'MUSIC OFF',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton.icon(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text(
                    'SETTINGS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'MINTED Board Game Companion',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
