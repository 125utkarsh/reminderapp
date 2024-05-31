import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RemindPage extends StatefulWidget {
  final Map? reminder;

  const RemindPage({Key? key, this.reminder}) : super(key: key);

  @override
  State<RemindPage> createState() => _RemindPageState();
}

class _RemindPageState extends State<RemindPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TimeOfDay? selectedTime;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      isEditMode = true;
      populateFields();
    }
  }

  void populateFields() {
    titleController.text = widget.reminder!['title'] ?? '';
    descriptionController.text = widget.reminder!['description'] ?? '';
    // Assuming the time is stored in a string format like 'HH:mm'
    final time = widget.reminder!['time']?.split(':');
    if (time != null && time.length == 2) {
      selectedTime =
          TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));
    }
  }

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Reminder' : 'New Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(hintText: 'Title'),
            ),

            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: 'Description'),
              minLines: 3,
              maxLines: 5,
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(selectedTime == null
                  ? 'Select Time'
                  : 'Selected Time: ${selectedTime!.hour}:${selectedTime!.minute}'),
              trailing: Icon(Icons.access_time),
              onTap: selectTime,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isEditMode ? updateReminder : addReminder,
              child: Text(isEditMode ? 'Update Reminder' : 'Add Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addReminder() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final time = selectedTime != null ? '${selectedTime!.hour}:${selectedTime!
        .minute}' : '';

    if (title.isEmpty || description.isEmpty || time.isEmpty) {
      // Handle empty fields
      return;
    }

    final url = 'https://api.nstack.in/v1/todos';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'title': title,
        'description': description,
        'time': time,
      },
    );

    if (response.statusCode == 201) {
      showSuccessMessage('Success');
      // Handle success
      Navigator.pop(context);
    } else {
      showFailedMessage('Failed');
      // Handle error
    }
  }

  Future<void> updateReminder() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final time = selectedTime != null ? '${selectedTime!.hour}:${selectedTime!
        .minute}' : '';

    if (title.isEmpty || description.isEmpty || time.isEmpty ||
        widget.reminder == null) {
      // Handle empty fields or missing reminder data
      return;
    }

    final url = 'https://api.nstack.in/v1/todos/${widget.reminder!['_id']}';
    final response = await http.put(
      Uri.parse(url),
      body: {
        'title': title,
        'description': description,
        'time': time,
      },
    );
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showFailedMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
