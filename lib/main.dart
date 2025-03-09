//Nikhil Goud Yeminedi
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(PlanManagerApp());
}

class Plan {
  String name;
  String description;
  DateTime date;
  String priority;
  bool isCompleted;
  String status;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    required this.priority,
    this.isCompleted = false,
    this.status = 'pending',
  });
}

class PlanManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PlanManagerScreen(),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  DateTime selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Plan? _draggedPlan;

  List<Plan> get _filteredPlans {
    return plans
        .where((plan) =>
            plan.date.year == selectedDate.year &&
            plan.date.month == selectedDate.month &&
            plan.date.day == selectedDate.day)
        .toList();
  }
}

void _addPlan(String name, String description, DateTime date, String priority,
    String status) {
  setState(() {
    plans.add(Plan(
        name: name,
        description: description,
        date: date,
        priority: priority,
        status: status));
    _sortPlans();
  });
}

void _updatePlan(int index, String name, String description, DateTime date,
    String priority, String status) {
  setState(() {
    Plan updatedPlan = plans[index];
    updatedPlan.name = name;
    updatedPlan.description = description;
    updatedPlan.date = date;
    updatedPlan.priority = priority;
    updatedPlan.status = status;
    _sortPlans();
  });
}

void _toggleCompletion(int index, DismissDirection direction) {
  setState(() {
    if (direction == DismissDirection.endToStart) {
      plans[index].isCompleted = true;
      plans[index].status = 'completed';
    } else if (direction == DismissDirection.startToEnd) {
      plans[index].isCompleted = false;
      plans[index].status = 'pending';
    }
  });
}

void _deletePlan(int index) {
  setState(() {
    plans.removeAt(index);
  });
}

void _sortPlans() {
  setState(() {
    plans.sort((a, b) {
      const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
      int priorityComparison =
          priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      return priorityComparison != 0
          ? priorityComparison
          : a.date.compareTo(b.date);
    });
  });
}

void _showCreatePlanDialog({int? index, DateTime? date}) {
  String name = index != null ? plans[index].name : '';
  String description = index != null ? plans[index].description : '';
  DateTime selectedPlanDate =
      date ?? (index != null ? plans[index].date : selectedDate);
  String selectedPriority = index != null ? plans[index].priority : 'Medium';
  String selectedStatus = index != null ? plans[index].status : 'pending';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title:
            Text(index == null ? "Create your own Plan" : "Modify your Plan"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Task Name"),
                controller: TextEditingController(text: name),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Basic Description"),
                controller: TextEditingController(text: description),
                onChanged: (value) => description = value,
                maxLines: 3,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Priority: "),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedPriority,
                    items: ['High', 'Medium', 'Low'].map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Status: "),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedStatus,
                    items: ['pending', 'completed'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.capitalize()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty) {
                if (index == null) {
                  _addPlan(name, description, selectedPlanDate,
                      selectedPriority, selectedStatus);
                } else {
                  _updatePlan(index, name, description, selectedPlanDate,
                      selectedPriority, selectedStatus);
                }
                Navigator.pop(context);
              }
            },
            child: Text(index == null ? "Add" : "Update"),
          ),
        ],
      );
    },
  );
}
