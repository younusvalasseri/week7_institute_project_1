import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/courses.dart';

class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final _coursesBox = Hive.box<Courses>('courses');

  void _showAddCourseDialog() {
    final formKey = GlobalKey<FormState>();
    String courseName = '';
    String courseDescription = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Course'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Course Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => courseName = value!,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Course Description'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => courseDescription = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final newCourse = Courses()
                    ..courseName = courseName
                    ..courseDescription = courseDescription;

                  _coursesBox.add(newCourse);
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditCourseDialog(Courses course) {
    final formKey = GlobalKey<FormState>();
    String courseName = course.courseName ?? '';
    String courseDescription = course.courseDescription ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Course'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: courseName,
                    decoration: const InputDecoration(labelText: 'Course Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => courseName = value!,
                  ),
                  TextFormField(
                    initialValue: courseDescription,
                    decoration:
                        const InputDecoration(labelText: 'Course Description'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => courseDescription = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  course.courseName = courseName;
                  course.courseDescription = courseDescription;
                  course.save();
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCourse(Courses course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this course?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                course.delete();
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _coursesBox.listenable(),
        builder: (context, Box<Courses> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No courses yet'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final course = box.getAt(index);
              return ListTile(
                title: Text(course?.courseName ?? 'No name'),
                subtitle: Text(course?.courseDescription ?? 'No description'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditCourseDialog(course!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteCourse(course!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        tooltip: 'Add Course',
        child: const Icon(Icons.add),
      ),
    );
  }
}
