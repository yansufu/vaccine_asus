import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'registerProv.dart';

class ForgotPasswordProviders extends StatefulWidget {
  const ForgotPasswordProviders({super.key});

  @override
  State<ForgotPasswordProviders> createState() => _ForgotPasswordProvidersState();
}

class _ForgotPasswordProvidersState extends State<ForgotPasswordProviders> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  void _forgotPasswordParent(String email) async {
    final url = Uri.parse(
        'https://vaccine-integration-main-xxocnw.laravel.cloud/api/forgot-password-prov');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reset link sent! Please check your email.")),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Something went wrong")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send reset email.")),
      );
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
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                onTap: () => Navigator.pop(context),
                child: const Icon(
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
        decoration: const BoxDecoration(
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
                  _buildInputField("Email", _emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _forgotPasswordParent(_emailController.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC0DA),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Send Reset Link",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.31),
            Container(
              height: screenHeight * 0.13,
              width: screenWidth * 0.1,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Images/parents_logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     const Text(
            //       "Don't have an account? ",
            //       style: TextStyle(
            //         color: Color.fromARGB(255, 83, 83, 83),
            //       ),
            //     ),
            //     GestureDetector(
            //       onTap: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => const RegisterProv()),
            //         );
            //       },
            //       child: const Text(
            //         " Register",
            //         style: TextStyle(
            //           color: Color(0xFF35C2C1),
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
