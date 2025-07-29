import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'navbar.dart';
import 'loginProv.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';


class RegisterProv extends StatefulWidget {
  const RegisterProv({super.key});

  @override
  State<RegisterProv> createState() => _RegisterProvState();
}

class _RegisterProvState extends State<RegisterProv> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _provNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController orgIdController = TextEditingController();
  int? _selectedOrgId;

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

  void _registerProvider() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      final provName = _provNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final org_id = _selectedOrgId ?? 1;

      try {
        final url = Uri.parse('https://vaccine-laravel-main-fi5xjq.laravel.cloud/api/provider');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': provName,
            'org_id' : org_id,
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final provId = data['Data']['id'];

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NavBar_prov(provID: provId)),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white10,
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
              child:  GestureDetector(
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
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/Images/bg_register.png"),
                fit: BoxFit.fill)
        ),
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
                  _buildInputField("Provider's Name", _provNameController),
                  _buildInputField("Email", _emailController, keyboardType: TextInputType.emailAddress),
                  _buildInputField("Password", _passwordController, obscure: true),
                  _buildInputField("Confirm Password", _confirmPasswordController, obscure: true),
                  _buildOrganizationField(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerProvider,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC0DA),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.17,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have account? ",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 83, 83, 83),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginProv()),
                    );
                  },
                  child: Text(
                    " Login",
                    style: TextStyle(
                      color: const Color(0xFF35C2C1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}