// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../models/player_model.dart';
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

  // Official Careers and Salaries from minted.final.pdf
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

  final List<String> _availableColors = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Purple',
    'Orange',
  ];

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
      _selectedPaths.add('College'); // Default path
      _selectedCareers.add(_collegeCareers.keys.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Setup (MINTED)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Number of Players (2-6):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: _numberOfPlayers,
                  items: [2, 3, 4, 5, 6].map((int value) {
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
                  String currentPath = _selectedPaths[index];
                  List<String> availableCareersList = currentPath == 'College'
                      ? _collegeCareers.keys.toList()
                      : _nonCollegeCareers.keys.toList();

                  // Ensure selected career exists in the current path list
                  if (!availableCareersList.contains(_selectedCareers[index])) {
                    _selectedCareers[index] = availableCareersList.first;
                  }

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
                          DropdownButtonFormField<String>(
                            value: _selectedColors[index],
                            decoration: const InputDecoration(
                              labelText: 'Token Color',
                            ),
                            items: _availableColors.map((colorName) {
                              return DropdownMenuItem(
                                value: colorName,
                                child: Text(colorName),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedColors[index] = val!;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: currentPath,
                                  decoration: const InputDecoration(
                                    labelText: 'Path',
                                  ),
                                  items: ['College', 'Non-College'].map((path) {
                                    return DropdownMenuItem(
                                      value: path,
                                      child: Text(path),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedPaths[index] = val!;
                                      _selectedCareers[index] = val == 'College'
                                          ? _collegeCareers.keys.first
                                          : _nonCollegeCareers.keys.first;
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
                                  decoration: const InputDecoration(
                                    labelText: 'Career',
                                  ),
                                  items: availableCareersList.map((career) {
                                    int salary = currentPath == 'College'
                                        ? _collegeCareers[career]!
                                        : _nonCollegeCareers[career]!;
                                    return DropdownMenuItem(
                                      value: career,
                                      child: Text('$career (${salary}M)'),
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
                List<Player> players = List.generate(_numberOfPlayers, (index) {
                  String path = _selectedPaths[index];
                  String career = _selectedCareers[index];
                  int salary = path == 'College'
                      ? _collegeCareers[career]!
                      : _nonCollegeCareers[career]!;

                  // Starting funds: 2500 mints total. College costs 500 mints.
                  int initialBalance = path == 'College' ? 2000 : 2500;

                  return Player(
                    id: 'p_${index + 1}',
                    name: _nameControllers[index].text.trim(),
                    color: _selectedColors[index],
                    pathType: path,
                    career: career,
                    salary: salary,
                    balance: initialBalance,
                  );
                });

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerProfileScreen(players: players),
                  ),
                );
              },
              child: const Text(
                'Start Game (2500 Mints Base)',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
