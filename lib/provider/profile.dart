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
  String? Name;

  TextEditingController nameController = TextEditingController();
  TextEditingController orgIdController = TextEditingController();
  int? _selectedOrgId;

  @override
  void initState() {
    super.initState();
    fetchProvData();
  }

  Widget _buildProviderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: orgIdController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE8ECF4),
            hintText: "Registered Posyandu",
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        suggestionsCallback: (pattern) async {
          final response = await http.get(Uri.parse('https://vaccine-laravel-main-otillt.laravel.cloud/api/organization?search=$pattern'));
          
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
        onSuggestionSelected: (dynamic suggestion) {
          orgIdController.text = suggestion['org_name'];
          _selectedOrgId = suggestion['id'];
        },
        validator: (value) {
          if (_selectedOrgId == null) {
            return 'Please select a valid posyandu from the list';
          }
          return null;
        },
      ),
    );
  }

  Future<void> fetchProvData() async {
  final url = Uri.parse('https://vaccine-laravel-main-otillt.laravel.cloud/api/provider/${widget.provID}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body); 

    setState(() {
      nameController.text = data['data']['name'] ?? '';
      Name = data['data']['name'];
      orgIdController.text = data['data']['organization']?['id']?.toString() ?? '';
      orgName = data['data']['organization']?['org_name'];
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
      'name': nameController.text,
      "org_id": _selectedOrgId ?? 1,
    };
    print("Sending payload: $payload");

    final response = await http.put(
      Uri.parse('https://vaccine-laravel-main-otillt.laravel.cloud/api/provider/${widget.provID}'),
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
    final String currentValue = controller.text;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: isEditing ? null : controller,
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
                    colors: [Color(0xFFFFC0DA), Color(0xFFFFC0DA).withOpacity(0.6)],
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
                      Name ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
                mainAxisAlignment: MainAxisAlignment.start,
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
              const SizedBox(height: 16),
              profileField('Name', nameController),
              _buildProviderField(),
            ],
          ),
        ),
      ),
    );
  }
}
