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

  // Toggle plan completion based on swipe direction
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
          title: Text(index == null ? "Create Plan" : "Edit Plan"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Plan Name"),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Description"),
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

  Color _getPlanColor(Plan plan) {
    if (plan.isCompleted || plan.status == 'completed') {
      return Colors.green.shade200;
    } else {
      switch (plan.priority) {
        case 'High':
          return const Color.fromARGB(255, 245, 7, 7);
        case 'Medium':
          return const Color.fromARGB(255, 233, 142, 6);
        case 'Low':
          return const Color.fromARGB(255, 10, 135, 238);
        default:
          return const Color.fromARGB(255, 200, 183, 183);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plan Manager"),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _sortPlans,
            tooltip: "Sort by priority",
          ),
        ],
      ),
      body: Column(
        children: [
          DragTarget<Plan>(
            onAccept: (plan) {
              setState(() {
                int planIndex = plans.indexOf(plan);
                plans[planIndex].date = selectedDate;
                _sortPlans();
              });
            },
            onWillAccept: (plan) => plan != null,
            builder: (context, candidateData, rejectedData) {
              return TableCalendar(
                focusedDay: selectedDate,
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    // Mark days that have plans
                    final hasPlans = plans.any((plan) =>
                        plan.date.year == date.year &&
                        plan.date.month == date.month &&
                        plan.date.day == date.day);

                    if (hasPlans) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              );
            },
          ),

          // New plan drag target area
          DragTarget<String>(
            onAccept: (data) {
              if (data == 'new_plan') {
                _showCreatePlanDialog(date: selectedDate);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: candidateData.isNotEmpty ? Colors.blue : Colors.grey,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    "Drop here to add a new plan for ${selectedDate.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            },
          ),

          // Label for plans on selected date
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Plans for ${selectedDate.toLocal().toString().split(' ')[0]}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // Draggable new plan option
          Draggable<String>(
            data: 'new_plan',
            feedback: Material(
              elevation: 4.0,
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text("New Plan"),
              ),
            ),
            childWhenDragging: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text("Drag to create"),
            ),
            child: Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8.0),
                  Text("Drag to add a new plan"),
                ],
              ),
            ),
          ),

          // List of plans for the selected date
          Expanded(
            child: _filteredPlans.isEmpty
                ? Center(child: Text("No plans for this date"))
                : ListView.builder(
                    itemCount: _filteredPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _filteredPlans[index];

                      // Make each plan item draggable
                      return LongPressDraggable<Plan>(
                        data: plan,
                        feedback: Material(
                          elevation: 4.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: _getPlanColor(plan),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(plan.name),
                          ),
                        ),
                        child: Dismissible(
                          key: Key("${plan.name}_${plans.indexOf(plan)}"),
                          onDismissed: (direction) {
                            int planIndex = plans.indexOf(plan);
                            _toggleCompletion(planIndex, direction);
                          },
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              return !plan.isCompleted;
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              return plan.isCompleted;
                            }
                            return false;
                          },
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.undo, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                          child: GestureDetector(
                            onDoubleTap: () {
                              // Show confirmation dialog before deletion
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Delete Plan"),
                                  content: Text(
                                      "Are you sure you want to delete '${plan.name}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        int planIndex = plans.indexOf(plan);
                                        _deletePlan(planIndex);
                                        Navigator.pop(context);
                                      },
                                      child: Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onLongPress: () {
                              int planIndex = plans.indexOf(plan);
                              _showCreatePlanDialog(index: planIndex);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getPlanColor(plan),
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2.0,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: ListTile(
                                title: Text(
                                  plan.name,
                                  style: TextStyle(
                                    decoration: plan.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(plan.description),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                            plan.priority,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          backgroundColor:
                                              _getPriorityColor(plan.priority),
                                          padding: EdgeInsets.zero,
                                          labelPadding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                        ),
                                        SizedBox(width: 8),
                                        Chip(
                                          label: Text(
                                            plan.status.capitalize(),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          backgroundColor:
                                              plan.status == 'completed'
                                                  ? Colors.green.shade100
                                                  : Colors.orange.shade100,
                                          padding: EdgeInsets.zero,
                                          labelPadding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  plan.isCompleted
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlanDialog(date: selectedDate),
        child: Icon(Icons.add),
        tooltip: "Create Plan",
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color.fromARGB(255, 231, 9, 31);
      case 'Medium':
        return const Color.fromARGB(255, 197, 125, 17);
      case 'Low':
        return const Color.fromARGB(255, 12, 115, 200);
      default:
        return const Color.fromARGB(255, 165, 157, 157);
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
