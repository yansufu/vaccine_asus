import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'navbar.dart';

class ChildFormPage extends StatefulWidget {
  final String uid;

  const ChildFormPage({super.key, required this.uid});

  @override
  State<ChildFormPage> createState() => _ChildFormPageState();
}

class ChildEntry {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController posyanduController = TextEditingController();
  int? selectedOrgId;
}

class _ChildFormPageState extends State<ChildFormPage> {
  List<ChildEntry> childrenForms = [];

  @override
  void initState() {
    super.initState();
    _addNewChildForm(); // Automatically add first child form on start
  }

  void _addNewChildForm() {
    setState(() {
      childrenForms.add(ChildEntry());
    });
  }

  Widget _buildInputField(String hint, TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onTap: onTap,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFE8ECF4),
          hintText: hint,
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
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $hint';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOrganizationField(ChildEntry child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: child.posyanduController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE8ECF4),
            hintText: "Registered Posyandu",
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        suggestionsCallback: (pattern) async {
          final response = await http.get(Uri.parse(
              'https://vaccine-laravel-main-otillt.laravel.cloud/api/organization?search=$pattern'));

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
          child.posyanduController.text = suggestion['org_name'];
          child.selectedOrgId = suggestion['id'];
        },
        validator: (value) {
          if (child.selectedOrgId == null) {
            return 'Please select a valid posyandu from the list';
          }
          return null;
        },
      ),
    );
  }

  void _selectDate(BuildContext context, ChildEntry child) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      child.dobController.text = formattedDate;
    }
  }

  Future<void> _submitAllChildren() async {
    List<Map<String, dynamic>> childDataList = [];
    bool allValid = true;

    for (var form in childrenForms) {
      if (!form.formKey.currentState!.validate()) {
        allValid = false;
      }
    }

    if (!allValid) return;

    for (var form in childrenForms) {
      childDataList.add({
        "name": form.nameController.text.trim(),
        "date_of_birth": form.dobController.text.trim(),
        "weight": double.tryParse(form.weightController.text.trim()) ?? 0.0,
        "height": double.tryParse(form.heightController.text.trim()) ?? 0.0,
        "medical_history": "none",
        "allergy": "none",
        "org_id": form.selectedOrgId ?? 1,
      });
    }

    int? firstChildId;

    for (int i = 0; i < childDataList.length; i++) {
      final response = await http.post(
        Uri.parse('https://vaccine-laravel-main-otillt.laravel.cloud/api/parent/${widget.uid}/children'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(childDataList[i]),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final childID = data['Data']['id'];

        if (i == 0) {
          firstChildId = childID;
        }
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add child. (${response.body})"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
        return;
      }
    }

    if (firstChildId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NavBar_screen(
            parentID: widget.uid,
            childID: firstChildId ?? 0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFC28CA5),
                    blurRadius: BorderSide.strokeAlignOutside,
                    offset: Offset(0, 0.5),
                  )
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); 
                },
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Color(0xFFC28CA5),
                ),
              ),
            ),
            const SizedBox(width: 20),
            const Text(
              "Ibu Digi",
              style: TextStyle(
                fontSize: 23,
                color: Color(0xFFFFC0DA),
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Tell us about your little ones",
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: childrenForms.length,
                itemBuilder: (context, index) {
                  final child = childrenForms[index];
                  return Form(
                    key: child.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField("Child's Name", child.nameController),
                        _buildInputField("Date of Birth", child.dobController,
                            readOnly: true,
                            onTap: () => _selectDate(context, child)),
                        _buildInputField("Weight (kg)", child.weightController,
                            keyboardType: TextInputType.number),
                        _buildInputField("Height (cm)", child.heightController,
                            keyboardType: TextInputType.number),
                        _buildOrganizationField(child),
                         SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addNewChildForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFFC28CA5),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFC28CA5)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 5),
                  Text("Add More Children"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAllChildren,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC0DA),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add Child',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
