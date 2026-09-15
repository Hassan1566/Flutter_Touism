// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../models/game_stat.dart';
import '../services/storage_service.dart';
import 'player_profile_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int _numberOfPlayers = 2;
  final List<TextEditingController> _nameControllers = [];
  final List<String> _selectedColors = [];
  final List<String> _selectedPaths = [];
  final List<String> _selectedCareers = [];

  final Map<String, int> _collegeCareers = {
    'Doctor': 150,
    'Engineer': 130,
    'Accountant': 120,
    'Psychologist': 100,
    'Architect': 120,
    'Lawyer': 150,
  };

  final Map<String, int> _nonCollegeCareers = {
    'Artist': 80,
    'Freelancer': 80,
    'Influencer': 120,
    'Farmer': 100,
    'Actor': 120,
    'Activist': 50,
  };

  final List<String> _availableColors = ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange'];

  @override
  void initState() {
    super.initState();
    _updatePlayerFields();
  }

  void _updatePlayerFields() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    _nameControllers.clear();
    _selectedColors.clear();
    _selectedPaths.clear();
    _selectedCareers.clear();

    for (int i = 0; i < _numberOfPlayers; i++) {
      _nameControllers.add(TextEditingController(text: 'Player ${i + 1}'));
      _selectedColors.add(_availableColors[i % _availableColors.length]);
      _selectedPaths.add('College');
      _selectedCareers.add(_collegeCareers.keys.first);
    }
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _startGame() async {
    final names = _nameControllers.map((controller) => controller.text.trim()).toList();
    if (names.any((name) => name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Every player must have a name.')));
      return;
    }

    final duplicateNames = names.length != names.toSet().length;
    if (duplicateNames) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Player names must be unique.')));
      return;
    }

    final players = List<Player>.generate(_numberOfPlayers, (index) {
      final path = _selectedPaths[index];
      final career = _selectedCareers[index];
      final salary = path == 'College' ? _collegeCareers[career]! : _nonCollegeCareers[career]!;
      final initialBalance = path == 'College' ? 2000 : 2500;

      return Player(
        id: index + 1,
        name: names[index],
        color: _selectedColors[index],
        pathType: path,
        career: career,
        salary: salary,
        balance: initialBalance,
      );
    });

    final gameState = GameState(players: players);
    await StorageService.saveGame(gameState);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PlayerProfileScreen(gameState: gameState)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Setup (MINTED)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Number of Players (2-6):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton<int>(
                  value: _numberOfPlayers,
                  items: [2, 3, 4, 5, 6].map((value) => DropdownMenuItem(value: value, child: Text('$value Players'))).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _numberOfPlayers = value;
                      _updatePlayerFields();
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _numberOfPlayers,
                itemBuilder: (context, index) {
                  final currentPath = _selectedPaths[index];
                  final careers = currentPath == 'College' ? _collegeCareers.keys.toList() : _nonCollegeCareers.keys.toList();
                  if (!careers.contains(_selectedCareers[index])) {
                    _selectedCareers[index] = careers.first;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Player ${index + 1} Configuration', style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextField(controller: _nameControllers[index], decoration: const InputDecoration(labelText: 'Player Name')),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedColors[index],
                            decoration: const InputDecoration(labelText: 'Token Color'),
                            items: _availableColors.map((color) => DropdownMenuItem(value: color, child: Text(color))).toList(),
                            onChanged: (value) => setState(() => _selectedColors[index] = value!),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: currentPath,
                                  decoration: const InputDecoration(labelText: 'Path'),
                                  items: ['College', 'Non-College'].map((path) => DropdownMenuItem(value: path, child: Text(path))).toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      _selectedPaths[index] = value;
                                      _selectedCareers[index] = value == 'College' ? _collegeCareers.keys.first : _nonCollegeCareers.keys.first;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _selectedCareers[index],
                                  decoration: const InputDecoration(labelText: 'Career'),
                                  items: careers.map((career) {
                                    final salary = currentPath == 'College' ? _collegeCareers[career]! : _nonCollegeCareers[career]!;
                                    return DropdownMenuItem(value: career, child: Text('$career (${salary}M)'));
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) setState(() => _selectedCareers[index] = value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: _startGame,
              child: const Text('Start Game (2500 Mints Base)', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
