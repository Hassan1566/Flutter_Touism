// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../services/quiz_service.dart';
import '../services/banking_service.dart';

import 'package:project/services/news_startup.dart';

class PlayerProfileScreen extends StatefulWidget {
  final List<Player> players;
  const PlayerProfileScreen({super.key, required this.players});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  int _activePlayerIndex = 0;
  int _currentYear = 1;

  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  void _nextTurn() {
    setState(() {
      if (_activePlayerIndex < widget.players.length - 1) {
        _activePlayerIndex++;
      } else {
        _activePlayerIndex = 0;
        _currentYear++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 Year $_currentYear has begun! All players prepare for a new round.',
            ),
            backgroundColor: Colors.deepPurple,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Player activePlayer = widget.players[_activePlayerIndex];
    Color playerThemeColor = _parseColor(activePlayer.color);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Profiles'),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Year $_currentYear',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<int>(
              value: _activePlayerIndex,
              dropdownColor: Colors.blueGrey,
              underline: const SizedBox(),
              items: List.generate(widget.players.length, (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Text(
                    widget.players[index].name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
              onChanged: (val) => setState(() => _activePlayerIndex = val!),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: playerThemeColor,
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
            activePlayer.history.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No tile calculations recorded yet for this player.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activePlayer.history.length,
                    itemBuilder: (context, index) {
                      var log = activePlayer.history[index];
                      return ListTile(
                        title: Text(log['title'] ?? 'Action'),
                        subtitle: Text('Result: ${log['result']}'),
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showQuizDialog(context, activePlayer, () {
                        setState(() {});
                      });
                    },
                    icon: const Icon(Icons.quiz),
                    label: const Text("Quiz"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showBankingDialog(context, activePlayer, () {
                        setState(() {});
                      });
                    },
                    icon: const Icon(Icons.account_balance),
                    label: const Text("Banking"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showNewsStartupDialog(context, activePlayer, () {
                        setState(() {});
                      });
                    },
                    icon: const Icon(Icons.newspaper),
                    label: const Text("News"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: _nextTurn,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  _activePlayerIndex == widget.players.length - 1
                      ? 'End Round & Advance Year'
                      : 'Pass to Next Player',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
