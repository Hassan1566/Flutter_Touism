import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minted/models/player_model.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

class QuizService {
  static final Random _random = Random();

  static const Map<String, int> rewards = {
    'Easy': 20,
    'Medium': 50,
    'Hard': 100,
  };

  static const List<QuizQuestion> _easyQuestions = [
    QuizQuestion(
      question: 'Which language is primarily used to build Flutter apps?',
      options: ['Dart', 'Java', 'Python', 'C++'],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question: 'What does CPU stand for?',
      options: [
        'Central Processing Unit',
        'Computer Personal Unit',
        'Central Program Utility',
        'Control Processing User',
      ],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question: 'How many players can play MINTED?',
      options: ['1-2', '2-6', '6-10', '10-12'],
      correctAnswer: 1,
    ),
  ];

  static const List<QuizQuestion> _mediumQuestions = [
    QuizQuestion(
      question: 'Which data structure follows FIFO?',
      options: ['Stack', 'Queue', 'Tree', 'Graph'],
      correctAnswer: 1,
    ),
    QuizQuestion(
      question: 'What does SQL stand for?',
      options: [
        'Structured Query Language',
        'Simple Question Language',
        'System Query Logic',
        'Structured Question List',
      ],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question: 'What is the reward for an Easy MINTED Quiz?',
      options: ['10 Mints', '20 Mints', '50 Mints', '100 Mints'],
      correctAnswer: 1,
    ),
  ];

  static const List<QuizQuestion> _hardQuestions = [
    QuizQuestion(
      question: 'Which principle hides internal implementation details?',
      options: ['Inheritance', 'Encapsulation', 'Polymorphism', 'Iteration'],
      correctAnswer: 1,
    ),
    QuizQuestion(
      question:
          'Which algorithm has average O(log n) search time on a balanced BST?',
      options: ['Linear Search', 'Binary Search', 'Tree Search', 'Bubble Sort'],
      correctAnswer: 2,
    ),
    QuizQuestion(
      question: 'What is the MINTED investment annual interest rate?',
      options: ['2%', '5%', '10%', '15%'],
      correctAnswer: 1,
    ),
  ];

  /// Opens the Quiz difficulty selection.
  static void showQuizDialog(
    BuildContext context,
    Player activePlayer,
    VoidCallback onUpdate,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('🧠 Quiz Challenge'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select difficulty level:'),
              const SizedBox(height: 12),

              _difficultyButton(dialogContext, activePlayer, 'Easy', onUpdate),

              const SizedBox(height: 8),

              _difficultyButton(
                dialogContext,
                activePlayer,
                'Medium',
                onUpdate,
              ),

              const SizedBox(height: 8),

              _difficultyButton(dialogContext, activePlayer, 'Hard', onUpdate),
            ],
          ),
        );
      },
    );
  }

  static Widget _difficultyButton(
    BuildContext context,
    Player player,
    String difficulty,
    VoidCallback onUpdate,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);

          _startQuiz(context, player, difficulty, onUpdate);
        },
        child: Text('$difficulty (${rewards[difficulty]} Mints)'),
      ),
    );
  }

  static void _startQuiz(
    BuildContext context,
    Player player,
    String difficulty,
    VoidCallback onUpdate,
  ) {
    final questions = _questionsForDifficulty(difficulty);

    final question = questions[_random.nextInt(questions.length)];

    int? selectedAnswer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (quizContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('🧠 $difficulty Quiz'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 16),

                  RadioGroup<int>(
                    groupValue: selectedAnswer,
                    onChanged: (value) {
                      setState(() {
                        selectedAnswer = value;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(question.options.length, (index) {
                        return RadioListTile<int>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(question.options[index]),
                          value: index,
                        );
                      }),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(quizContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: selectedAnswer == null
                      ? null
                      : () {
                          final correct =
                              selectedAnswer == question.correctAnswer;

                          Navigator.pop(quizContext);

                          _showResult(
                            context,
                            player,
                            difficulty,
                            correct,
                            onUpdate,
                          );
                        },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static List<QuizQuestion> _questionsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return _easyQuestions;

      case 'Medium':
        return _mediumQuestions;

      case 'Hard':
        return _hardQuestions;

      default:
        return _easyQuestions;
    }
  }

  static void _showResult(
    BuildContext context,
    Player player,
    String difficulty,
    bool correct,
    VoidCallback onUpdate,
  ) {
    final reward = rewards[difficulty]!;

    showDialog(
      context: context,
      builder: (resultContext) {
        return AlertDialog(
          title: Text(correct ? '🎉 Correct!' : '❌ Incorrect'),
          content: Text(
            correct
                ? 'You earned $reward Mints!'
                : 'No reward this time. Try again!',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (correct) {
                  player.addMoney(reward);
                  player.addHistory('Quiz ($difficulty)', reward);
                } else {
                  player.addHistory('Quiz ($difficulty) - Incorrect', 0);
                }

                onUpdate();

                Navigator.pop(resultContext);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}
