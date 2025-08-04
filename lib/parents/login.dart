import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'registerParents.dart';
import 'forgotPassword.dart';


class LoginParents extends StatefulWidget {
  const LoginParents({super.key});

  @override
  State<LoginParents> createState() => _LoginParentsState();
}

class _LoginParentsState extends State<LoginParents> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _loginParent(String email, String password, BuildContext context) async {
  if (_formKey.currentState!.validate()) {

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final url = Uri.parse('https://vaccine-integration-main-xxocnw.laravel.cloud/api/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parentId = data['parent_id']; 
        final childID = data['child_id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('parent_id', parentId);
        await prefs.setInt('child_id', childID ?? 0);

        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavBar_screen(
          parentID : parentId.toString(),
          childID : childID ?? 0,
        )
        ),
      );
      } else {
        final error = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Login Response"),
            content: Text(response.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
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
      child: Stack(
        children: [TextFormField(
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
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Images/bg_login.png'), 
            fit: BoxFit.cover, 
          ),
        ),
        child: ListView(
          children: [
            Text(
              "Welcome back!",
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            Text(
              "Glad to see you again!",
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
                  _buildInputField("Email", _emailController),
                  _buildInputField("Password", _passwordController, obscure: true),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordParents()),
                          );
                        },
                        child: Text("Forgot Password?"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      _loginParent(email, password, context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC0DA),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 16),),
                  ),

                ],
              ),

            ),
            SizedBox(height: screenHeight * 0.2,),
            Container(
              height: screenHeight * 0.13,
              width: screenWidth * 0.1,
              alignment: Alignment.center,
              decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Images/parents_logo.png'), 
                fit: BoxFit.contain, 
              ),
            ),
            ),
            SizedBox(height: screenHeight * 0.005,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                        "Don't have account? ",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 83, 83, 83),
                        ),
                      ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RegisterParents()),
                    );
                  },
                  child: Text(
                        " Register",
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
