import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChildFormPage extends StatefulWidget {
  final String uid;

  const ChildFormPage({super.key, required this.uid});

  @override
  State<ChildFormPage> createState() => _ChildFormPageState();
}

class _ChildFormPageState extends State<ChildFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _posyanduController = TextEditingController();

  Future<void> _addChild() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> childData = {
        "childName": _childNameController.text.trim(),
        "dateOfBirth": _dobController.text.trim(),
        "weight": double.tryParse(_weightController.text.trim()) ?? 0.0,
        "height": double.tryParse(_heightController.text.trim()) ?? 0.0,
        "posyandu": _posyanduController.text.trim(),
      };

      final response = await http.post(
        Uri.parse('http://YOUR_BACKEND_URL/child/${widget.uid}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(childData),
      );

      if (response.statusCode == 200) {
        _childNameController.clear();
        _dobController.clear();
        _weightController.clear();
        _heightController.clear();
        _posyanduController.clear();

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Child added successfully!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add child. (${response.statusCode})"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      }
    }
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

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2020),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      _dobController.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Child"),
        backgroundColor: const Color(0xFFFFC0DA),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              "Child Information",
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputField("Child's Name", _childNameController),
                  _buildInputField("Date of Birth", _dobController,
                      readOnly: true, onTap: _selectDate),
                  _buildInputField("Weight (kg)", _weightController, keyboardType: TextInputType.number),
                  _buildInputField("Height (cm)", _heightController, keyboardType: TextInputType.number),
                  _buildInputField("Registered Posyandu", _posyanduController),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addChild,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC0DA),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add Child',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
