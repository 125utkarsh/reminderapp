import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reminderapp/reminderpage.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {

    super.initState();
    fetchReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Reminder List")),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: Text("No Reminder")),
        replacement: RefreshIndicator(
          onRefresh: fetchReminders,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item['_id'];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item['title'] ?? ''),
                subtitle: Text(item['description'] ?? ''),

                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit'){
                      // add edit
                      navigateToEditPage(item);
                    }
                    else if (value == 'delete') {
                      deleteReminder(item['_id']);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        child: Text('Delete'),
                        value: 'delete',
                      ),
                      const PopupMenuItem(
                        child: Text('Edit'),
                        value: 'edit',
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Text("Add"),
      ),
    );
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => RemindPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchReminders();

  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => RemindPage(reminder: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchReminders();

  }

  Future<void> deleteReminder(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        items.removeWhere((element) => element['_id'] == id);
      });
    } else {
      // Handle error
    }
  }

  Future<void> fetchReminders() async {
    setState(() {
      isLoading = true;
    });
    final url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = json['items'] as List<dynamic>;
      setState(() {
        items = List<Map<String, dynamic>>.from(result);
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }
}
