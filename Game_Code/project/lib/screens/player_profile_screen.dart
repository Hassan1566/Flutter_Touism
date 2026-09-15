import 'package:flutter/material.dart';

import '../models/game_stat.dart';
import '../models/player_model.dart';
import '../services/banking_service.dart';
import '../services/news_service.dart';
import '../services/quiz_service.dart';
import '../services/startup_service.dart';
import '../services/storage_service.dart';
import '../widgets/game_over_service.dart';

class PlayerProfileScreen extends StatefulWidget {
  final GameState gameState;

  const PlayerProfileScreen({super.key, required this.gameState});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
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

  Future<void> _saveGame({bool showMessage = false}) async {
    final saved = await StorageService.saveGame(widget.gameState);

    if (!mounted || !showMessage) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? 'Game saved successfully.' : 'Could not save game.',
        ),
      ),
    );
  }

  Future<void> _afterAction() async {
    if (!mounted) return;
    setState(() {});
    await _saveGame();
  }

  Future<void> _nextTurn() async {
    final completedRound = widget.gameState.nextTurn();

    setState(() {});
    await _saveGame();

    if (!mounted) return;

    if (widget.gameState.isGameFinished) {
      showGameOverDialog(context, widget.gameState, () async {
        await StorageService.deleteSavedGame();
        if (!mounted) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      });
      return;
    }

    if (completedRound) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Year ${widget.gameState.currentYear} started.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePlayer = widget.gameState.activePlayer;
    final playerThemeColor = _parseColor(activePlayer.color);
    final netWorth = widget.gameState.calculateNetWorth(activePlayer);

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
                'Year ${widget.gameState.currentYear}',
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<int>(
              value: widget.gameState.activePlayerIndex,
              dropdownColor: Colors.blueGrey,
              underline: const SizedBox(),
              items: List.generate(widget.gameState.players.length, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(
                    widget.gameState.players[index].name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  widget.gameState.activePlayerIndex = value;
                });
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Profile',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
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
                    _valueRow(
                      'Balance (Mints)',
                      '${activePlayer.balance} Mints',
                      valueColor: Colors.green,
                    ),
                    _valueRow(
                      'Fixed Salary',
                      '${activePlayer.salary} Mints / Payday',
                    ),
                    _valueRow('Path Type', activePlayer.pathType),
                    _valueRow('Career', activePlayer.career),
                    _valueRow(
                      'Startup Fund',
                      '${activePlayer.startupFund} Mints',
                      valueColor: Colors.deepOrange,
                    ),
                    _valueRow(
                      'Active Loan',
                      '${activePlayer.loan?.principal ?? 0} Mints',
                      valueColor: Colors.red,
                    ),
                    _valueRow(
                      'Active Investment',
                      '${activePlayer.investment?.principal ?? 0} Mints',
                      valueColor: Colors.blue,
                    ),
                    _valueRow(
                      'Net Worth',
                      '$netWorth Mints',
                      valueColor: Colors.green,
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
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No calculations recorded yet for this player.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activePlayer.history.length,
                    itemBuilder: (context, index) {
                      final log = activePlayer.history[index];
                      return ListTile(
                        leading: Icon(
                          log.amount >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: log.amount >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(log.action),
                        subtitle: Text(
                          '${log.date.toLocal()}\n'
                          'Result: ${log.amount > 0 ? '+' : ''}${log.amount} Mints',
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        QuizService.showQuizDialog(
                          context,
                          activePlayer,
                          () => _afterAction(),
                        );
                      },
                      icon: const Icon(Icons.quiz),
                      label: const Text('Quiz'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        BankingService.showBankingDialog(
                          context,
                          activePlayer,
                          () => _afterAction(),
                        );
                      },
                      icon: const Icon(Icons.account_balance),
                      label: const Text('Banking'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        NewsService.showNewsDialog(
                          context,
                          widget.gameState,
                          () => _afterAction(),
                        );
                      },
                      icon: const Icon(Icons.newspaper),
                      label: const Text('News'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        StartupService.showStartupEvent(
                          context: context,
                          player: activePlayer,
                          onUpdated: () => _afterAction(),
                        );
                      },
                      icon: const Icon(Icons.business),
                      label: const Text('Startup'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _saveGame(showMessage: true),
                      icon: const Icon(Icons.save),
                      label: const Text('Save Game'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _nextTurn,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        widget.gameState.activePlayerIndex ==
                                widget.gameState.players.length - 1
                            ? 'End Round'
                            : 'Next Player',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _valueRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
