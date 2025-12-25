import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../models/bubble.dart';
import '../services/game_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/empty_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameService _gameService = GameService();
  int _score = 0;
  int _lives = 3;
  bool _isGameActive = false;
  int _timeLeft = 60;
  int _record = 0;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  Timer? _updateTimer;
  final List<Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRecord() async {
    final record = await _gameService.loadRecord();
    setState(() {
      _record = record;
    });
  }

  Future<void> _saveRecord() async {
    if (_score > _record) {
      await _gameService.saveRecord(_score);
      setState(() {
        _record = _score;
      });
    }
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _isGameActive = true;
      _timeLeft = 60;
      _bubbles.clear();
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }
      _spawnBubble();
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          timer.cancel();
          _endGame();
        }
      });
    });

    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }
      _updateBubbles();
    });
  }

  void _spawnBubble() {
    if (!_isGameActive) return;

    setState(() {
      _bubbles.add(Bubble(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        x: _random.nextDouble() * 0.8 + 0.1,
        y: 0.0,
        speed: _random.nextDouble() * 0.005 + 0.002,
        color: _getRandomColor(),
        points: _random.nextInt(5) + 1,
      ));
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _popBubble(Bubble bubble) {
    setState(() {
      _bubbles.removeWhere((b) => b.id == bubble.id);
      _score += bubble.points;
    });
  }

  void _missBubble() {
    setState(() {
      _lives--;
      if (_lives <= 0) {
        _endGame();
      }
    });
  }

  void _endGame() {
    setState(() {
      _isGameActive = false;
    });
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _saveRecord();

    final isNewRecord = _score > _record;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNewRecord ? '🎉 Новый рекорд!' : 'Игра окончена!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ваш счет: $_score'),
            const SizedBox(height: 8),
            Text('Рекорд: $_record'),
            if (isNewRecord) ...[
              const SizedBox(height: 8),
              const Text(
                'Поздравляем! Вы побили рекорд!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _bubbles.clear();
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateBubbles() {
    if (!_isGameActive) return;

    setState(() {
      final bubblesToRemove = <Bubble>[];
      for (var bubble in _bubbles) {
        bubble.y += bubble.speed;
        if (bubble.y > 1.0) {
          bubblesToRemove.add(bubble);
        }
      }
      for (var bubble in bubblesToRemove) {
        _bubbles.remove(bubble);
        _missBubble();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Игра Таймкиллер'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple.shade100,
                  Colors.purple.shade50,
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.purple.withValues(alpha: 0.2),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatCard(
                          icon: Icons.star,
                          label: 'Счет',
                          value: _score.toString(),
                          color: Colors.orange,
                        ),
                        StatCard(
                          icon: Icons.favorite,
                          label: 'Жизни',
                          value: _lives.toString(),
                          color: Colors.red,
                        ),
                        StatCard(
                          icon: Icons.timer,
                          label: 'Время',
                          value: _timeLeft.toString(),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Рекорд: $_record',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) {
                        if (!_isGameActive) return;
                        final double tapX =
                            details.localPosition.dx / constraints.maxWidth;
                        final double tapY =
                            details.localPosition.dy / constraints.maxHeight;

                        Bubble? bubbleToPop;
                        for (var bubble in _bubbles) {
                          final distance = sqrt(
                            pow(tapX - bubble.x, 2) + pow(tapY - bubble.y, 2),
                          );
                          if (distance < 0.08) {
                            bubbleToPop = bubble;
                            break;
                          }
                        }

                        if (bubbleToPop != null) {
                          _popBubble(bubbleToPop);
                        }
                      },
                      child: Stack(
                        children: [
                          ..._bubbles.map((bubble) => Positioned(
                                left: bubble.x * constraints.maxWidth - 40,
                                top: bubble.y * constraints.maxHeight - 40,
                                child: GestureDetector(
                                  onTap: () => _popBubble(bubble),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: bubble.color,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: bubble.color
                                              .withValues(alpha: 0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${bubble.points}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                          if (!_isGameActive && _bubbles.isEmpty)
                            const EmptyState(
                              icon: Icons.games,
                              title: 'Игра Таймкиллер',
                              subtitle: 'Лопайте пузыри и набирайте очки!',
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (!_isGameActive && _bubbles.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Начать игру'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
