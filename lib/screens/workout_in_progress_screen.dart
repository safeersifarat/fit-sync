import 'package:flutter/material.dart';

class WorkoutInProgressScreen extends StatelessWidget {
  const WorkoutInProgressScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('$title in progress'),
      ),
      body: const Center(
        child: Text(
          'Workout session placeholder',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
