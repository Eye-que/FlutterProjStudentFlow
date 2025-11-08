import 'package:flutter/material.dart';
import 'dart:math';

/// Study Tips Screen
/// Displays random motivational quotes and study tips
class StudyTipsScreen extends StatefulWidget {
  const StudyTipsScreen({super.key});

  @override
  State<StudyTipsScreen> createState() => _StudyTipsScreenState();
}

class _StudyTipsScreenState extends State<StudyTipsScreen> {
  final List<Map<String, String>> _tips = [
    {
      'title': 'Pomodoro Technique',
      'tip':
          'Study for 25 minutes, then take a 5-minute break. After 4 cycles, take a longer break of 15-30 minutes.',
      'icon': '🍅',
    },
    {
      'title': 'Active Recall',
      'tip':
          'Instead of just re-reading notes, test yourself. Close your book and try to recall what you learned.',
      'icon': '🧠',
    },
    {
      'title': 'Spaced Repetition',
      'tip':
          'Review material multiple times over increasing intervals. This helps move information to long-term memory.',
      'icon': '📚',
    },
    {
      'title': 'Stay Organized',
      'tip':
          'Keep your study space clean and organized. Use planners and to-do lists to track your assignments.',
      'icon': '📋',
    },
    {
      'title': 'Get Enough Sleep',
      'tip':
          'Aim for 7-9 hours of sleep per night. Sleep helps consolidate memories and improves focus.',
      'icon': '😴',
    },
    {
      'title': 'Break It Down',
      'tip':
          'Divide large tasks into smaller, manageable chunks. This makes studying less overwhelming.',
      'icon': '✂️',
    },
    {
      'title': 'Stay Hydrated',
      'tip':
          'Drink plenty of water throughout the day. Dehydration can affect concentration and cognitive function.',
      'icon': '💧',
    },
    {
      'title': 'Find Your Peak Time',
      'tip':
          'Identify when you\'re most alert and productive. Schedule your most challenging tasks during this time.',
      'icon': '⏰',
    },
  ];

  final List<String> _quotes = [
    'The only way to do great work is to love what you do. - Steve Jobs',
    'Success is the sum of small efforts repeated day in and day out. - Robert Collier',
    'Don\'t watch the clock; do what it does. Keep going. - Sam Levenson',
    'The expert in anything was once a beginner. - Helen Hayes',
    'You don\'t have to be great to start, but you have to start to be great. - Zig Ziglar',
    'The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt',
    'Education is the most powerful weapon which you can use to change the world. - Nelson Mandela',
    'The harder you work, the luckier you get. - Gary Player',
    'Believe you can and you\'re halfway there. - Theodore Roosevelt',
    'It always seems impossible until it\'s done. - Nelson Mandela',
  ];

  int _currentTipIndex = 0;
  int _currentQuoteIndex = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _shuffleTips();
  }

  void _shuffleTips() {
    setState(() {
      _currentTipIndex = _random.nextInt(_tips.length);
      _currentQuoteIndex = _random.nextInt(_quotes.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Tips & Motivation'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _shuffleTips();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Motivational Quote Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.format_quote,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _quotes[_currentQuoteIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Study Tip Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        _tips[_currentTipIndex]['icon']!,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _tips[_currentTipIndex]['title']!,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _tips[_currentTipIndex]['tip']!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[700],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Get New Tip Button
              ElevatedButton.icon(
                onPressed: _shuffleTips,
                icon: const Icon(Icons.refresh),
                label: const Text('Get New Tip'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // All Tips Section
              Text(
                'All Study Tips',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tips.length,
                itemBuilder: (context, index) {
                  final tip = _tips[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Text(
                        tip['icon']!,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        tip['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(tip['tip']!),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

