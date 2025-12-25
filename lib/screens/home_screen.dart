import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
import 'todo_screen.dart';
import 'time_management_screen.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuCard(
              icon: Icons.check_circle,
              title: 'TODO Список',
              subtitle: 'Управление задачами',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TodoScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            MenuCard(
              icon: Icons.timer,
              title: 'Тайм-менеджмент',
              subtitle: 'Таймеры и статистика',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TimeManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            MenuCard(
              icon: Icons.games,
              title: 'Игра Таймкиллер',
              subtitle: 'Развлечение и отдых',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
