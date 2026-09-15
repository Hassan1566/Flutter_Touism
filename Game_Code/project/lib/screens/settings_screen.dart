import 'package:flutter/material.dart';

import '../services/music_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _musicEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await MusicService.isEnabled();
    if (!mounted) return;
    setState(() => _musicEnabled = enabled);
  }

  Future<void> _toggleMusic(bool value) async {
    setState(() => _musicEnabled = value);
    await MusicService.setEnabled(value);
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _resetGame() async {
    if (!await _confirm('Reset current game?', 'This removes the current saved game progress.', 'Reset')) return;
    await StorageService.deleteSavedGame();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current game reset.')));
  }

  Future<void> _clearData() async {
    if (!await _confirm('Clear saved data?', 'This removes saved game data, history, and music preference.', 'Clear')) return;
    await StorageService.deleteSavedGame();
    await MusicService.resetToDefault();
    if (!mounted) return;
    setState(() => _musicEnabled = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All saved data cleared.')));
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'MINTED',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Hybrid Board Game Companion',
      children: const [
        SizedBox(height: 16),
        Text('MINTED supports player setup, profiles, app-related events, hybrid calculations, banking, history, and game tracking. The physical board, dice, movement, and cash remain outside the app.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Music'),
              subtitle: Text(_musicEnabled ? 'Music is ON' : 'Music is OFF'),
              secondary: Icon(_musicEnabled ? Icons.music_note : Icons.music_off),
              value: _musicEnabled,
              onChanged: _toggleMusic,
            ),
          ),
          const SizedBox(height: 12),
          Card(child: ListTile(leading: const Icon(Icons.restart_alt), title: const Text('Reset Current Game'), subtitle: const Text('Remove current saved game'), onTap: _resetGame)),
          const SizedBox(height: 12),
          Card(child: ListTile(leading: const Icon(Icons.delete_outline), title: const Text('Clear Saved Data'), subtitle: const Text('Remove saved game, history and preferences'), onTap: _clearData)),
          const SizedBox(height: 12),
          Card(child: ListTile(leading: const Icon(Icons.info_outline), title: const Text('About'), onTap: _showAbout)),
          const SizedBox(height: 12),
          Card(child: ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Back to Home'), onTap: () => Navigator.pop(context))),
        ],
      ),
    );
  }
}
