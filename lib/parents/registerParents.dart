import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'childForm.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class RegisterParents extends StatefulWidget {
  const RegisterParents({super.key});

  @override
  State<RegisterParents> createState() => _RegisterParentsState();
}

class _RegisterParentsState extends State<RegisterParents> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _registerParent() async {
  if (_formKey.currentState!.validate()) {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    final parentName = _parentNameController.text.trim();
    final nik = _nikController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final url = Uri.parse('https://vaccine-laravel-main-otillt.laravel.cloud/api/parent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': parentName,
          'NIK': nik,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parentId = data['Data']['id']; 

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChildFormPage(uid: parentId.toString())),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${error['message']}")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}

  Widget _buildInputField(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Color(0xFFC28CA5),
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
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              "Hello!",
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            Text(
              "Register to get started",
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputField("Parent's Name", _parentNameController),
                  _buildInputField("NIK", _nikController, keyboardType: TextInputType.number),
                  _buildInputField("Email", _emailController, keyboardType: TextInputType.emailAddress),
                  _buildInputField("Password", _passwordController, obscure: true),
                  _buildInputField("Confirm Password", _confirmPasswordController, obscure: true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerParent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC0DA),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Register',
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
