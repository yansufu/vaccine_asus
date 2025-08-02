import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginProv.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:vaccine_app/roleSelect.dart';


class ProfilePage extends StatefulWidget {
  final int provID;

  const ProfilePage({super.key, required this.provID});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  String? orgName;
  String? provName;

  TextEditingController nameController = TextEditingController();
  TextEditingController orgIdController = TextEditingController();
  int? _selectedOrgId;


  @override
  void initState() {
    super.initState();
    fetchProvData();
  }

  Widget _buildOrganizationField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TypeAheadField(
        suggestionsCallback: (pattern) async {
          final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/organization'));

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

  Future<void> fetchProvData() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/provider/${widget.provID}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!mounted) return;

      setState(() {
        orgName = data['organization']['org_name'];
        provName = data['name'];

        nameController.text = data['name'];
        orgIdController.text = data['organization']['org_name'];
        _selectedOrgId = data['organization']['id']; // optional: retain original ID
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile data')),
      );
    }
  }


  Future<void> updateProvData() async {
    final payload = {
      "name": nameController.text,
      "org_id": _selectedOrgId ?? 1,
    };
    print("Sending payload: $payload");

    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/provider/${widget.provID}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider data updated successfully')),
      );
    } else {
      print('Failed to update: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update provider data')),
      );
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      fetchProvData(),
    ]);
  }

  void _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('provID');

    // Clear all preference
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => roleSelect()),
    );
  }


  Widget profileField(String label, TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: !isEditing || readOnly,
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
          fillColor: isEditing ? Colors.white : const Color(0xFFE8ECF4),
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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(105),
        child: Stack(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 254, 171, 205), Color.fromARGB(255, 254, 171, 205).withOpacity(0.6)],
                    begin: Alignment.topLeft,
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
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),),
                    const SizedBox(height: 12),
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
                    Row(children: [
                      SizedBox(width: 20,),
                      Text(
                        provName ?? 'Loading...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],)
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
                },
                itemBuilder: (BuildContext context) => [
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: Icon(isEditing ? Icons.check : Icons.edit, size: 20, color: Colors.grey),
                    onPressed: () {
                      if (isEditing) updateProvData();
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                  ),
                ],
              ),
              profileField('Name', nameController),
              _buildOrganizationField(),
            ],
          ),
        ),
      ),
    );
  }
}