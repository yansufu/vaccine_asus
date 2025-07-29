import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'navbar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import "package:vaccine_app/roleSelect.dart";


class ProfilePage extends StatefulWidget {
  final int childID;
  final String parentID;

  const ProfilePage({super.key, required this.parentID, required this.childID});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  String? orgName;
  String? childName;
  DateTime? childDOB;
  double weight = 0.0;
  double height = 0.0;

  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController medicalHistoryController = TextEditingController();
  TextEditingController allergyController = TextEditingController();
  TextEditingController orgIdController = TextEditingController();
  int? _selectedOrgId;

  @override
  void initState() {
    super.initState();
    fetchChildData();
  }

  String calculateAge(DateTime childDOB) {
    final now = DateTime.now();
    final age = now.difference(childDOB);
    final months = (age.inDays / 30).floor();
    final days = age.inDays % 30;
    return "$months months, $days days";
  }

  Widget _buildOrganizationField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TypeAheadField(
        suggestionsCallback: (pattern) async {
          final response = await http.get(Uri.parse('https://vaccine-laravel-main-fi5xjq.laravel.cloud/api/organization'));

          if (response.statusCode == 200) {
            final Map<String, dynamic> jsonResponse = json.decode(response.body);
            return jsonResponse['data'] ?? [];
          } else {
            return [];
          }
        },
        itemBuilder: (context, dynamic suggestion) {
          return ListTile(
            title: Text(suggestion['org_name']),
          );
        },
        onSelected: (dynamic suggestion) {
          orgIdController.text = suggestion['org_name'];
          _selectedOrgId = suggestion['id'];
        },
        builder: (context, controller, focusNode) {
          orgIdController = controller;
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE8ECF4),
              hintText: "Registered Posyandu",
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }


  Future<void> fetchChildData() async {
  final url = Uri.parse('https://vaccine-laravel-main-fi5xjq.laravel.cloud/api/child/${widget.childID}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body); // NO ['data']

    setState(() {
      nameController.text = data['name'];
      childName = data['name'];
      dobController.text = data['date_of_birth'];
      childDOB = DateTime.tryParse(data['date_of_birth']) ?? DateTime.now();
      weightController.text = (data['weight'] ?? 0.0).toString();
      heightController.text = (data['height'] ?? 0.0).toString();
      medicalHistoryController.text = data['medical_history'];
      allergyController.text = data['allergy'];
      orgIdController.text = data['organization']['org_name'].toString();
      orgName = data['organization']?['org_name'];
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to load profile data')),
    );
  }
}

  Future<void> updateChildData() async {
    final payload = {
      'name': nameController.text,
      'date_of_birth': dobController.text.trim(),
      'weight': double.tryParse(weightController.text),
      'height': double.tryParse(heightController.text),
      'medical_history': medicalHistoryController.text,
      'allergy': allergyController.text,
      "org_id": _selectedOrgId ?? 1,
    };
    print("Sending payload: $payload");

    final response = await http.put(
      Uri.parse('https://vaccine-laravel-main-fi5xjq.laravel.cloud/api/child/${widget.childID}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child data updated successfully')),
      );
    } else {
      print('Failed to update: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update child data')),
      );
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      fetchChildData(),
    ]);
  }

  void _handleLogout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('parent_id');
  await prefs.remove('child_id');

  // Clear all preference
  await prefs.clear();

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => roleSelect()), 
  );
}

  void _switchChild(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final parentId = prefs.getInt('parent_id');

  // Fetch children BY PARENT
  final url = Uri.parse('https://vaccine-laravel-main-fi5xjq.laravel.cloud/api/childByParent/$parentId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List children = data['data'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select a Child'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Card(
                  child: ListTile(
                    title: Text(child['name']),
                    onTap: () async {
                      await prefs.setInt('child_id', child['id']);
                      Navigator.of(context).pop();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NavBar_screen(
                            parentID: parentId.toString(),
                            childID: child['id'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  } else {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text("Failed to fetch children"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }
}

  void _selectDate() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
      String formattedDate = pickedDate.toUtc().toIso8601String();
        dobController.text = formattedDate;
      }
    }

  Widget profileField(String label, TextEditingController controller, 
  {bool readOnly = false, VoidCallback? onTap, TextInputType? type}) {
    final String currentValue = controller.text;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        onTap: onTap, 
        keyboardType: type ?? TextInputType.text,
        cursorColor: Colors.pink,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: isEditing ? Colors.white : Color(0xFFE8ECF4),
          hintText: isEditing ? currentValue : null,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Stack(
          children: [
            AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 254, 171, 205), Color.fromARGB(255, 254, 171, 205).withOpacity(0.6)],                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.only(left: 20, top: 50, right: 20, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ibu Digi",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            orgName ?? 'Loading...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      childName ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      childDOB != null ? calculateAge(childDOB!) : 'Loading...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            // POP UP MENU
            Positioned(
              top: 50,
              right: 20,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout(context);
                  }
                  else{
                    _switchChild(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'switch',
                    child: Text('Switch Child'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Log Out'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: Icon(isEditing ? Icons.check : Icons.edit, size: 20, color: Colors.grey),
                    onPressed: () {
                      if (isEditing) updateChildData();
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              profileField('Name', nameController),
              profileField("Date of Birth", dobController,
                      readOnly: true, onTap: _selectDate),
              profileField('Weight (Kg)', weightController, type: TextInputType.number),
              profileField('Height (cm)', heightController, type: TextInputType.number),
              profileField('Medical History', medicalHistoryController),
              profileField('Allergy', allergyController),
              _buildOrganizationField(),
            ],
          ),
        ),
      ),
    );
  }
}
