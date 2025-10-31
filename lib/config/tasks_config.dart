import 'dart:convert';
import 'package:flutter/services.dart';

class TasksConfig {
  static List<TaskItem> _tasks = [];
  
  static List<TaskItem> get tasks => _tasks;
  
  static Future<void> load() async {
    final String jsonString = await rootBundle.loadString('assets/config/tasks.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    _tasks = (jsonData['tasks'] as List)
        .map((task) => TaskItem.fromJson(task))
        .toList();
  }
}

class TaskItem {
  final String id;
  final String name;
  final String description;

  const TaskItem({
    required this.id,
    required this.name,
    required this.description,
  });
  
  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
}