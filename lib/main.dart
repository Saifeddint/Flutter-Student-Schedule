import 'package:flutter/material.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> instructors = [
    'All',
    'Michael Wong',
    'Sarah Lee',
    'Bob Johnson',
    'Saifeddin Altawarh',
    'Jane Doe',
  ];
  String selectedInstructor = 'All';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 4, // number of tabs
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 38, 51, 61),
          appBar: AppBar(
            title: const Center(child: Text('Student Schedule',
              //style: const TextStyle(
                //color: Color.fromARGB(255, 38, 51, 61),
                  //  ),
                  )
                ),
            backgroundColor: const Color.fromARGB(255, 8, 163, 124),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Monday'),
                Tab(text: 'Tuesday'),
                Tab(text: 'Wednesday'),
                Tab(text: 'Thursday'),
              ],
            ),
          ),
          body: Column(
            children: [
              _buildFilters(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTimeline(context, 'M', selectedInstructor),
                    _buildTimeline(context, 'T', selectedInstructor),
                    _buildTimeline(context, 'W', selectedInstructor),
                    _buildTimeline(context, 'R', selectedInstructor),
                  ],
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedInstructor,
            decoration: InputDecoration(
              labelText: '\nInstructor',
              labelStyle: TextStyle(
                      color: Color.fromARGB(255, 8, 163, 124),
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  selectedInstructor = value;
                }
              });
            },
            items: instructors
                .map((instructor) =>
                DropdownMenuItem<String>(
                  value: instructor,
                  child: Text(instructor),
                ))
                .toList(),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
    backgroundColor: Color.fromARGB(255, 8, 163, 124),
  ),
          onPressed: () {
            _buildFilters();
          },
          child: const Text('Filter'),
        ),
        const SizedBox(width: 16),
      ],
    );
  }


  Widget _buildTimeline(BuildContext context, String day, String instructor) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context).loadString('assets/schedule.json'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var data = json.decode(snapshot.data.toString());
          List<Course> courses = [];
          for (var course in data) {
            if (course['Course Days'].contains(day)) {
              var c = Course.fromJson(course);
              if (instructor == 'All' || c.instructor == instructor) {
                courses.add(c);
              }
            }
          }
          courses.sort((a, b) => a.timing.compareTo(b.timing));
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (BuildContext context, int index) {
                final controller = TextEditingController();
                return ListTile(
                  title: Text(courses[index].name,
                    style: const TextStyle(
                    color: Color.fromARGB(255, 8, 163, 124),
                    ),
                  ),
                  subtitle: Text(courses[index].timing,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 8, 163, 124),
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Course Details'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Course Code: ${courses[index].code}'),
                              Text('Course Name: ${courses[index].name}'),
                              Text('Course Days: ${courses[index].days}'),
                              Text('Course Timing: ${courses[index].timing}'),
                              Text('Instructor: ${courses[index].instructor}'),
                              Text('Building: ${courses[index].building}'),
                              Text('Room: ${courses[index].room}'),
                              const SizedBox(height: 16.0),
                              TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText: 'Add Note Here',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Save'),
                              onPressed: () {
                                final notes = controller.text;
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }
}
  class Course {
  final String code;
  final String name;
  final String days;
  final String timing;
  final String instructor;
  final String building;
  final String room;

  Course({
    required this.code,
    required this.name,
    required this.days,
    required this.timing,
    required this.instructor,
    required this.building,
    required this.room,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['Course Code'],
      name: json['Course Name'],
      days: json['Course Days'],
      timing: json['Course Timing'],
      instructor: json['Instructor'],
      building: json['Building'],
      room: json['Room'],
    );
  }
}