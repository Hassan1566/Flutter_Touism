import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📖 How to Play MINTED')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hybrid Gameplay Guide',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'MINTED is a hybrid board game combining a physical tabletop experience with this companion app.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            _buildSectionCard(
              title: '🎲 What Remains Physical',
              description: '• The physical game board is used for movement.\n• Dice rolling is completely physical.\n• Cash/money handling is done with physical notes.\n• Chance cards and the business spinner happen on the board.',
              color: Colors.orange.shade50,
              borderColor: Colors.orange,
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: '📱 What the App Handles',
              description: '• Player setup, profile creation, and career tracking.\n• Banking records (tracking 10% loans and 5% investments).\n• App-only global News events and Quiz reward challenges.\n• Automatic tracking of yearly paydays and final Net Worth calculations.',
              color: Colors.blue.shade50,
              borderColor: Colors.blue,
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: '🏁 Game End & Winning',
              description: '• The game runs for a fixed number of rounds (Year 3).\n• Once the final year concludes, the app automatically calculates each player\'s total net worth (Cash + Investments - Loans) and crowns the richest player.',
              color: Colors.purple.shade50,
              borderColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String description,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }
}
