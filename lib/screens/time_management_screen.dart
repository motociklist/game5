import 'package:flutter/material.dart';
import 'dart:async';
import '../models/timer_session.dart';
import '../services/timer_service.dart';
import '../utils/time_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/time_display.dart';
import '../widgets/empty_state.dart';

class TimeManagementScreen extends StatefulWidget {
  const TimeManagementScreen({super.key});

  @override
  State<TimeManagementScreen> createState() => _TimeManagementScreenState();
}

class _TimeManagementScreenState extends State<TimeManagementScreen> {
  final TimerService _timerService = TimerService();
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  String _currentTaskName = '';
  final TextEditingController _taskController = TextEditingController();
  List<TimerSession> _sessions = [];
  int _totalTimeToday = 0;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _timerService.loadSessions();
    setState(() {
      _sessions = sessions;
    });
    _loadTodayTime();
  }

  Future<void> _loadTodayTime() async {
    await _timerService.loadTodayTime();
    _calculateTodayTime();
  }

  Future<void> _saveTodayTime() async {
    await _timerService.saveTodayTime(_totalTimeToday);
  }

  Future<void> _saveSessions() async {
    await _timerService.saveSessions(_sessions);
  }

  void _calculateTodayTime() {
    final todayTime = _timerService.calculateTodayTime(_sessions);
    setState(() {
      _totalTimeToday = todayTime;
    });
    _saveTodayTime();
  }

  void _startTimer() {
    if (_taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название задачи')),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      _currentTaskName = _taskController.text.trim();
      _seconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();

    if (_isRunning && _seconds > 0) {
      final session = TimerSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _currentTaskName,
        durationSeconds: _seconds,
        startTime: DateTime.now().subtract(Duration(seconds: _seconds)),
        endTime: DateTime.now(),
      );

      setState(() {
        _sessions.add(session);
        _isRunning = false;
        _seconds = 0;
        _currentTaskName = '';
        _taskController.clear();
      });

      _saveSessions();
      _calculateTodayTime();
    } else {
      setState(() {
        _isRunning = false;
        _seconds = 0;
        _currentTaskName = '';
        _taskController.clear();
      });
    }
  }

  void _deleteSession(String id) {
    setState(() {
      _sessions.removeWhere((session) => session.id == id);
    });
    _saveSessions();
    _calculateTodayTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тайм-менеджмент'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.blue.withValues(alpha: 0.1),
                      child: Column(
                        children: [
                          TimeDisplay(
                            seconds: _totalTimeToday,
                            fontSize: 32,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Время сегодня',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _taskController,
                            decoration: InputDecoration(
                              hintText: 'Название задачи',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.task),
                            ),
                            enabled: !_isRunning,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                TimeDisplay(
                                  seconds: _seconds,
                                  fontSize: 48,
                                  color: Colors.blue,
                                ),
                                if (_currentTaskName.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _currentTaskName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_isRunning)
                                ElevatedButton.icon(
                                  onPressed: _startTimer,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Старт'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                )
                              else
                                ElevatedButton.icon(
                                  onPressed: _stopTimer,
                                  icon: const Icon(Icons.stop),
                                  label: const Text('Стоп'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'История сессий',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Всего: ${_sessions.length}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    if (_sessions.isEmpty)
                      const Expanded(
                        child: EmptyState(
                          icon: Icons.timer_off,
                          title: 'Нет сессий',
                          subtitle: 'Запустите таймер для начала работы',
                        ),
                      )
                    else
                      ..._sessions.reversed.map((session) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading:
                                const Icon(Icons.timer, color: Colors.blue),
                            title: Text(session.name),
                            subtitle: Text(
                              DateFormatter.formatDateTime(session.startTime),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  TimeFormatter.formatTime(
                                      session.durationSeconds),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _deleteSession(session.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
