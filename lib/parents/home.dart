import 'package:flutter/material.dart';
import 'navbar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeParent extends StatefulWidget {
  final String parentID;
  final int childID;

  const HomeParent({super.key, required this.parentID, required this.childID});

  @override
  State<HomeParent> createState() => _HomeParentState();
}

class _HomeParentState extends State<HomeParent> {
  List<dynamic> vaccinationStatusList = [];
  List<dynamic> vaccinationList = [];
  String? orgName;
  String? childName;
  DateTime? childDOB;
  Map<String, dynamic>? childData;

  @override
  void initState() {
    super.initState();
    fetchChildPeriod();
    fetchChildData();
    fetchChildStatus();
  }

  Future<void> fetchChildPeriod() async {
  final response = await http.get(Uri.parse('https://vaccine-laravel-main-otillt.laravel.cloud/api/child/${widget.childID}/vaccinations/status'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    setState(() {
      vaccinationStatusList = data;
    });
  }

}
  
  Future<void> fetchChildStatus() async {
  final response = await http.get(Uri.parse('https://vaccine-laravel-main-otillt.laravel.cloud/api/child/${widget.childID}/vaccinations'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    setState(() {
      vaccinationList = data;
    });
  }
}

  Future<void> fetchChildData()async {
    final response = await http.get(Uri.parse('https://vaccine-laravel-main-otillt.laravel.cloud/api/child/${widget.childID}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        orgName = data['organization']['org_name'];
        childName = data['name'];
        childDOB = DateTime.parse(data['date_of_birth']);
      });
    }
  }

  Future<void> _handleRefresh() async {
  await Future.wait([
    fetchChildData(),
    fetchChildStatus(),
    fetchChildPeriod(),
  ]);
}

  //CALCULATE AGE
  String calculateAge(DateTime childDOB) {
    final now = DateTime.now();
    final age = now.difference(childDOB);
    final months = (age.inDays / 30).floor();
    final days = age.inDays % 30;
    return "$months months, $days days";
  }

  int getMonthAge(DateTime childDOB) {
    final now = DateTime.now();
    return (now.difference(childDOB).inDays / 30).floor();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFC0DA),
                Color(0xFFFFC0DA).withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        toolbarHeight: 1,
      ),
      body: RefreshIndicator( onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
                children: [
                  //--------------------------------------HEADER--------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFFC0DA),
                          Color(0xFFFFC0DA).withOpacity(0.5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ibu Digi",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Serif',
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                            SizedBox(width: 4),
                            Text(
                              orgName ?? 'Loading...',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          childName ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          childDOB != null ? calculateAge(childDOB!) : 'Loading...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //--------------------------------------BODY--------------------------------------------
                  //VACCINE PERIOD CONTAINER--------------------------------------------------------------
                  Container(
                    width: screenWidth * 0.95,
                    margin: EdgeInsets.symmetric(vertical: 15.0),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.topLeft,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: BorderSide.strokeAlignOutside,
                              offset: Offset(0, 0.5)
                          )
                        ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Vaccine Period",
                          style:
                          TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                          ),
                        ),
                        Text("4 months",
                          style: TextStyle(
                              color: Colors.red
                          ),
                        ),
                        SizedBox(height: 10.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: vaccinationStatusList.map<Widget>((vaccine) {
                              final String name = vaccine['name'];
                              final bool status = vaccine['status'];

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 5.0),
                                    Icon(
                                      status == true
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      color: status == true
                                          ? Colors.lightGreenAccent
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  ),

                  //PRIMARY VACCINE TABLE CONTAINER--------------------------------------------------------------
                  Container(
                    alignment: Alignment.topLeft,
                    width: screenWidth * 0.90,
                    child: Text("Primary Vaccine Report",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),),
                  ),
                  Container(
                    width: screenWidth * 0.95,
                    margin: EdgeInsets.symmetric(vertical: 15.0),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.topLeft,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: BorderSide.strokeAlignOutside,
                              offset: Offset(0, 0.5)
                          )
                        ]
                    ),
                    child:
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Vaccination Status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),),
                            Row(
                              children: [
                                Text("See All",
                                  style: TextStyle(color: Colors.grey),),
                                Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          border: TableBorder.all(color: Colors.grey.shade300),
                          children: [
                            // Table Header
                            const TableRow(
                              decoration: BoxDecoration(color: Color(0xFFFBF6F8)),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Vaccine Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),

                            // Table Rows from API data
                            ...vaccinationList.map((item) {
                              final vaccineName = item['vaccine']['name'] ?? 'Unknown';
                              final isCompleted = item['is_completed'] ?? false;

                              return TableRow(
                                decoration: const BoxDecoration(color: Color(0xFFFDFDFD)),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(vaccineName),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      isCompleted ? 'Completed' : 'Not Completed',
                                      style: TextStyle(
                                        color: isCompleted ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      ],
                    ),
                  )
                ]
            )
          ],
        ),
      ),)
      
    );
  }
}
