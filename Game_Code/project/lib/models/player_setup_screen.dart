// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../models/player_model.dart';
import 'player_profile_screen.dart'; // We'll navigate here next

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

  // Sample career options based on PDF game rules
  final List<String> _availableCareers = [
    'Engineer',
    'Doctor',
    'Business',
    'Artist',
  ];
  final List<String> _availableColors = ['Red', 'Blue', 'Green', 'Yellow'];

  @override
  void initState() {
    super.initState();
    _updatePlayerFields();
  }

  void _updatePlayerFields() {
    _nameControllers.clear();
    _selectedColors.clear();
    _selectedPaths.clear();
    _selectedCareers.clear();

    for (int i = 0; i < _numberOfPlayers; i++) {
      _nameControllers.add(TextEditingController(text: 'Player ${i + 1}'));
      _selectedColors.add(_availableColors[i % _availableColors.length]);
      _selectedPaths.add('Degree');
      _selectedCareers.add(_availableCareers[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Number of Players:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: _numberOfPlayers,
                  items: [2, 3, 4].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value Players'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _numberOfPlayers = newValue!;
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
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Player ${index + 1} Configuration',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: _nameControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Player Name',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedPaths[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Path',
                                  ),
                                  items: ['Degree', 'Non-Degree'].map((path) {
                                    return DropdownMenuItem(
                                      value: path,
                                      child: Text(path),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(
                                    () => _selectedPaths[index] = val!,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCareers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Career',
                                  ),
                                  items: _availableCareers.map((career) {
                                    return DropdownMenuItem(
                                      value: career,
                                      child: Text(career),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(
                                    () => _selectedCareers[index] = val!,
                                  ),
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
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                // Create players list
                List<Player> players = List.generate(_numberOfPlayers, (index) {
                  return Player(
                    id: 'p_${index + 1}',
                    name: _nameControllers[index].text.trim(),
                    color: _selectedColors[index],
                    pathType: _selectedPaths[index],
                    career: _selectedCareers[index],
                  );
                });

                // Navigate to Profile Screen passing the players list
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerProfileScreen(players: players),
                  ),
                );
              },
              child: const Text('Start Game', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
