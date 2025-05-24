import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State variables
  String age = "00y:04m:24d";
  String dob = "04/11/2024";
  double weight = 15;
  double height = 90;
  String gender = "Female";

  late TextEditingController weightController;
  late TextEditingController heightController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController(text: weight.toString());
    heightController = TextEditingController(text: height.toString());

    // Optionally simulate a loading delay or fetch from backend
    // setState(() => isLoading = true);
    // Future.delayed(Duration(seconds: 1), () {
    //   setState(() => isLoading = false);
    // });
  }

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFFC0DA), const Color(0xFFFFC0DA).withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            padding: const EdgeInsets.only(left: 20, top: 50, right: 20, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ibu Digi", style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Posyandu Jambangan, Candi Sidoarjo",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text("Annisa Delicia Yansaf",
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                Text(age, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Body check", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Icon(Icons.edit, size: 20, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InputChip(
                          label: Text(age),
                          backgroundColor: Colors.grey.shade100,
                          onPressed: () {},
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("/"),
                      ),
                      Expanded(
                        child: InputChip(
                          label: Text(dob),
                          backgroundColor: Colors.grey.shade100,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Weight",
                            suffixText: "Kg",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              setState(() => weight = parsed);
                              // TODO: Call backend update here
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Height",
                            suffixText: "cm",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              setState(() => height = parsed);
                              // TODO: Call backend update here
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      hintText: gender,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("weight/height ratio", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Stunting: low risk", style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC0DA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text("Chart Image Here", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Vaccine portfolio", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF8FA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pink.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Can be improved!",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                            SizedBox(width: 6),
                            Text("Missing 1 vaccination(s) this period"),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 20),
                            SizedBox(width: 6),
                            Text("Missing 1 overall vaccination(s)"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text("See details >", style: TextStyle(color: Colors.pink)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
