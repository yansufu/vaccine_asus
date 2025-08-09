import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class GenerateQRPage extends StatefulWidget {
  final int provID;
  const GenerateQRPage({super.key, required this.provID});

  @override
  State<GenerateQRPage> createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> vaccineOptions = [];
  // List<int> periodOptions = [];
  // List<Map<String, dynamic>> periodData = [];
  List<VaccinationFormModel> formModels = [];

  String? selectedVaccineName;
  String? orgName;
  String? provName;
  bool is_event = false;

  @override
  void initState() {
    super.initState();
    fetchVaccineCategories();
    fetchProvData();
    formModels.add(VaccinationFormModel());
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

  // Future<void> fetchPeriodsByCategory(int categoryId, int index) async {
  //   final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/vaccineByCat/$categoryId'));
  //
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //
  //     setState(() {
  //       formModels[index].periodData = List<Map<String, dynamic>>.from(data['data']);
  //       formModels[index].periodOptions = formModels[index].periodData.map((item) => item['period'] as int).toList();
  //
  //       formModels[index].selectedPeriod = null;
  //       formModels[index].selectedVaccineId = null;
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to load periods')),
  //     );
  //   }
  // }


  void _showQRPopup() {
    final uuid = Uuid();
    String? eventId;

    if (is_event) {
      eventId = uuid.v4();
    }

    final List<Map<String, dynamic>> data = formModels.map((form) => {
      "event_id": eventId,
      "vaccine_category": form.selectedCategoryId,
      "lot_id": form.lotIdController.text.trim(),
      "prov_id": widget.provID.toString(),
      "notes": form.notesController.text.trim(),
    }).toList();

    print("shown in the QR: $data");

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
        preferredSize: const Size.fromHeight(125),
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
        body: SingleChildScrollView(
          child: Padding(
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
              Row(
                children: [
                  Text("Is an event?"),
                  Checkbox(value: is_event, onChanged:
                      (value) {
                    setState(() {
                      is_event = value ?? false;
                    });}
                  ),
                ],),

            ...formModels.asMap().entries.map((entry) {
              final index = entry.key;
              final model = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              // Vaccine Dropdown
              DropdownButtonFormField<int>(
                value: formModels[index].selectedCategoryId,
                items: vaccineOptions.map((vaccine) {
                  return DropdownMenuItem<int>(
                    value: vaccine['id'],
                    child: Text(vaccine['category']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    formModels[index].selectedCategoryId = value;
                  });

                  //fetchPeriodsByCategory(value!, index);
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
              // DropdownButtonFormField<int>(
              //   value: formModels[index].selectedPeriod,
              //   items: formModels[index].periodOptions.map((period) {
              //     return DropdownMenuItem<int>(
              //       value: period,
              //       child: Text('Period $period'),
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       formModels[index].selectedPeriod = value;
              //       final matchedRecord = formModels[index].periodData.firstWhere(
              //             (item) => item['period'] == value,
              //         orElse: () => {},
              //       );
              //       if (matchedRecord != null) {
              //         formModels[index].selectedVaccineId = matchedRecord['id'];
              //       } else {
              //         formModels[index].selectedVaccineId = null;
              //       }
              //
              //     });
              //   },
              //   decoration: InputDecoration(
              //     hintText: 'Select period',
              //     filled: true,
              //     fillColor: const Color(0xFFF7F7F7),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //       borderSide: BorderSide.none,
              //     ),
              //   ),
              //   validator: (value) => value == null ? 'Please select a period' : null,
              // ),
              //
              // const SizedBox(height: 20),

              // Lot ID Field
              TextFormField(
                controller: model.lotIdController,
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
                  const SizedBox(height: 20),

              // Notes Field
              TextFormField(
                controller: model.notesController,
                decoration: InputDecoration(
                  hintText: 'Add notes (max 255)',
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

                  const SizedBox(height: 30),
                  Divider(),
                ],
              );
            }),

              // Add Forms Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    formModels.add(VaccinationFormModel());
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button background
                  side: BorderSide(color: Color.fromARGB(255, 254, 171, 205), width: 2), // Border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),),
                icon: const Icon(Icons.add_circle_outline, color: Colors.black,),
                label: const Text("Add Another Vaccination", style: TextStyle(color: Colors.black),),
            ),),

              SizedBox(
                height: 40,
              ),
              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final List<Map<String, dynamic>> payload = [];

                      for (final form in formModels) {
                        if (form.selectedCategoryId != null &&
                            form.lotIdController.text.trim().isNotEmpty) {
                          payload.add({
                            "event_id": is_event,
                            "vaccine_category": form.selectedCategoryId,
                            "prov_id": widget.provID,
                            "lot_id": form.lotIdController.text.trim(),
                            "notes": form.notesController.text.trim(),
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please complete all form fields')),
                          );
                          return;
                        }
                      }

                      _showQRPopup();

                      print("Generated payload: $payload");
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
        ),
    );
  }
}

class VaccinationFormModel {
  int? selectedCategoryId;
  int? selectedPeriod;
  int? selectedVaccineId;
  List<Map<String, dynamic>> periodData = [];
  List<int> periodOptions = [];

  final TextEditingController lotIdController;
  final TextEditingController notesController;

  VaccinationFormModel()
      : lotIdController = TextEditingController(),
        notesController = TextEditingController();
}

