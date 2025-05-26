import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GenerateQRPage extends StatefulWidget {
  final int provID;
  const GenerateQRPage({super.key, required this.provID});

  @override
  State<GenerateQRPage> createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController lotIdController = TextEditingController();

  List<Map<String, dynamic>> vaccineOptions = [];
  List<int> periodOptions = [];
  List<Map<String, dynamic>> periodData = [];

  int? selectedVaccineId;
  String? selectedVaccineName;
  int? selectedPeriod;

  @override
  void initState() {
    super.initState();
    fetchVaccineCategories();
  }

  Future<void> fetchVaccineCategories() async {
    final response = await http.get(Uri.parse('https://vaccine-laravel-main-otillt.laravel.cloud/api/category'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        vaccineOptions = List<Map<String, dynamic>>.from(data['data']);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vaccine categories')),
      );
    }
  }

  Future<void> fetchPeriodsByCategory(int categoryId) async {
    final response = await http.get(Uri.parse('https://vaccine-laravel-main-otillt.laravel.cloud/api/vaccineByCat/$categoryId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        periodData = List<Map<String, dynamic>>.from(data['data']);
        periodOptions = periodData.map((item) => item['period'] as int).toList();

        selectedPeriod = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load periods')),
      );
    }
  }


  void _showQRPopup(int vaccineId, String lotId, int provId) {
    final data = {
      "vaccine_id": vaccineId,
      "lot_id": lotId,
      "prov_id": provId.toString(),
    };

    final jsonStr = jsonEncode(data);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('QR Code'),
        content: SizedBox(
          height: 220,
          width: 220,
          child: QrImageView(
            data: jsonStr,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFC0DA), Color(0xFFFFC0DA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
          alignment: Alignment.bottomLeft,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Posyandu Jambangan, Candi Sidoarjo',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                'Dr. Lilik',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate vaccine QR',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Vaccine Dropdown
              DropdownButtonFormField<int>(
                value: selectedVaccineId,
                items: vaccineOptions.map((vaccine) {
                  return DropdownMenuItem<int>(
                    value: vaccine['id'],
                    child: Text(vaccine['category']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVaccineId = value;
                  });

                  fetchPeriodsByCategory(value!);
                },
                decoration: InputDecoration(
                  hintText: 'Vaccine name',
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null ? 'Please select a vaccine' : null,
              ),

              const SizedBox(height: 20),

              // Period Dropdown
              DropdownButtonFormField<int>(
                value: selectedPeriod,
                items: periodOptions.map((period) {
                  return DropdownMenuItem<int>(
                    value: period,
                    child: Text('Period $period'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select period',
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null ? 'Please select a period' : null,
              ),

              const SizedBox(height: 20),

              // Lot ID Field
              TextFormField(
                controller: lotIdController,
                decoration: InputDecoration(
                  hintText: 'Lot ID',
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter Lot ID' : null,
              ),

              const SizedBox(height: 40),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedVaccineId != null) {
                        _showQRPopup(
                          selectedVaccineId!,
                          lotIdController.text.trim(),
                          widget.provID,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a vaccine')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCB799A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Generate',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
