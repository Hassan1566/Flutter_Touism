import 'package:flutter/material.dart';

import '../models/player_model.dart';

class PlayerProfileScreen extends StatefulWidget {
  final List<Player> players;
  const PlayerProfileScreen({super.key, required this.players});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  int _activePlayerIndex = 0;

  @override
  Widget build(BuildContext context) {
    Player activePlayer = widget.players[_activePlayerIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profiles'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<int>(
              value: _activePlayerIndex,
              dropdownColor: Colors.blueGrey,
              items: List.generate(widget.players.length, (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Text(
                    widget.players[index].name,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }),
              onChanged: (val) => setState(() => _activePlayerIndex = val!),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Profile',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activePlayer.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Balance (Mints):',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${activePlayer.balance} Mints',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fixed Salary:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${activePlayer.salary} Mints / Payday',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Path Type:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Chip(label: Text(activePlayer.pathType)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Career:', style: TextStyle(fontSize: 16)),
                        Text(
                          activePlayer.career,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'App-Related Values & History Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: activePlayer.history.isEmpty
                  ? const Center(
                      child: Text(
                        'No tile calculations recorded yet for this player.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: activePlayer.history.length,
                      itemBuilder: (context, index) {
                        var log = activePlayer.history[index];
                        return ListTile(
                          title: Text(log['title'] ?? 'Action'),
                          subtitle: Text('Result: ${log['result']}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
