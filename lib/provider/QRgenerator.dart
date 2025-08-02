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

  int? selectedCategoryId;
  int? selectedVaccineId;
  String? selectedVaccineName;
  int? selectedPeriod;
  String? orgName;
  String? provName;

  @override
  void initState() {
    super.initState();
    fetchVaccineCategories();
    fetchProvData();
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
      });
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile data')),
      );
    }
  }
  Future<void> fetchVaccineCategories() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/category'));

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
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/vaccineByCat/$categoryId'));

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
          ],
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
                value: selectedCategoryId,
                items: vaccineOptions.map((vaccine) {
                  return DropdownMenuItem<int>(
                    value: vaccine['id'],
                    child: Text(vaccine['category']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
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
                    final matchedRecord = periodData.firstWhere(
                          (item) => item['period'] == value,
                      orElse: () => {},
                    );
                    selectedVaccineId = matchedRecord['id'];

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
                      if (selectedCategoryId != null) {
                        _showQRPopup(
                          selectedVaccineId!,
                          lotIdController.text.trim(),
                          widget.provID,
                        );
                        print('Vaccine ID: $selectedVaccineId, Lot ID: ${lotIdController.text.trim()}, Provider ID: ${widget.provID}');

                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a vaccine')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 254, 171, 205),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Generate',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white),
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