import 'package:flutter/material.dart';
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
  List<dynamic> vaccinationThisPeriodList = [];
  List<dynamic> vaccinationNextPeriodList = [];
  List<dynamic> vaccinationList = [];
  String? orgName;
  String? selectedGender;
  String? childName;
  DateTime? childDOB;
  Map<String, dynamic>? childData;

  @override
  void initState() {
    super.initState();
    fetchChildPeriod();
    fetchNextPeriod();
    fetchChildData();
    fetchChildStatus();
  }

  Future<void> fetchChildPeriod() async {
  final response = await http.get(Uri.parse('https://vaccine-integration-main-xxocnw.laravel.cloud/api/child/${widget.childID}/vaccinations/status'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    setState(() {
      vaccinationThisPeriodList = data;
    });
  }

}

  Future<void> fetchNextPeriod() async {
  final response = await http.get(Uri.parse('https://vaccine-integration-main-xxocnw.laravel.cloud/api/child/${widget.childID}/vaccinations/nextStatus'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    setState(() {
      vaccinationNextPeriodList = data;
    });
  }

}
  
  Future<void> fetchChildStatus() async {
  final response = await http.get(Uri.parse('https://vaccine-integration-main-xxocnw.laravel.cloud/api/child/${widget.childID}/vaccinations'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    setState(() {
      vaccinationList = data;
    });
  }
}

  Future<void> fetchChildData()async {
    final response = await http.get(Uri.parse('https://vaccine-integration-main-xxocnw.laravel.cloud/api/child/${widget.childID}'));
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
  String calculateAge(DateTime dob) {
    final now = DateTime.now();

    int years = now.year - dob.year;
    int months = now.month - dob.month;
    int days = now.day - dob.day;

    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final totalMonths = (years * 12) + months;
    return "$totalMonths months, $days days";
  }


  //CALCULATE UPCOMING AGE

  // String calculateUpcomingAge(DateTime childDOB) {
  //   final now = DateTime.now();
  //   final age = now.difference(childDOB);
  //   final months = ((age.inDays / 30) + 1).floor();
  //   return "$months months";
  // }

  int getMonthAge(DateTime childDOB) {
    final now = DateTime.now();
    return (now.difference(childDOB).inDays / 30).floor();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(131),
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
                      style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Serif', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
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
                    Row(
                      children: [
                        SizedBox(width: 20,),
                        Text(
                        childName ?? 'Loading...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ],
                    ),
                    Row(children: [
                      SizedBox(width: 20,),
                      Text(
                      childDOB != null ? calculateAge(childDOB!) : 'Loading...',
                      style: TextStyle(color: Colors.white70),
                    ),
                    ],)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      body: RefreshIndicator( onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
                children: [
                  //--------------------------------------BODY--------------------------------------------
                  //VACCINE PERIOD CONTAINER--------------------------------------------------------------
                  Container(
                    //margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                    margin: EdgeInsets.only(top: 15, left: 10, right:10),
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
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
                              fontSize: 16
                          ),
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Icon(Icons.timer, size: 15, color: const Color.fromARGB(255, 187, 234, 246),),
                            SizedBox(width: 5,),
                            Text(childDOB != null ? calculateAge(childDOB!).trim() : 'Loading...',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: vaccinationThisPeriodList.map<Widget>((vaccine) {
                              final String name = vaccine['name'];
                              final bool status = vaccine['status'] == 1 || vaccine['status'] == true;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                  Container(
                    color: Colors.black,
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10, bottom:15, left:10 ),
                    padding:  EdgeInsets.all(15),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 217, 218, 229),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: BorderSide.strokeAlignOutside,
                              offset: Offset(0, 0.5)
                          ),
                        ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Upcoming...",
                          style:
                          TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                        SizedBox(height: 10.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: vaccinationNextPeriodList.map<Widget>((vaccine) {
                              final String name = vaccine['name'];
                              final bool status = vaccine['status'] == 1 || vaccine['status'] == true;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                    alignment: Alignment.topCenter,
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
                            // Row(
                            //   children: [
                            //     Text("See All",
                            //       style: TextStyle(color: Colors.grey),),
                            //     Icon(
                            //       Icons.keyboard_arrow_right_rounded,
                            //       color: Colors.grey,
                            //     )
                            //   ],
                            // ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        SingleChildScrollView(
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(),
                              1: FlexColumnWidth(),
                            },
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
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
                                final vaccinePeriod = item['vaccine']['period'] ?? 'Unknown';
                                final bool isCompleted = item['is_completed'] == 1 || item['is_completed'] == true;
                                final vaccinationDate = item['updated_at'] ?? 'Unknown';
                                final providerNote = item['note'] ?? 'No note';
                                final lotId = item['lot_id'] ?? '-';
                                final provider = item['provider']?['name']?.toString() ?? '-';
                                final location = item['provider']?['organization']?['org_name'] ?? 'Not specified';

                                return TableRow(
                                  decoration: const BoxDecoration(color: Color(0xFFFDFDFD)),
                                  children: [
                                    TableCell(
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Vaccination Details'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Vaccine Name: $vaccineName'),
                                                  Text('Period: $vaccinePeriod months'),
                                                  Text('Status: ${isCompleted ? 'Completed' : 'Not Completed'}'),
                                                  Text('Lot ID: $lotId'),
                                                  Text('Name: $childName'),
                                                  Text('Location: $location'),
                                                  Text('Note: $providerNote'),
                                                  if (isCompleted) Text('Date: $vaccinationDate'),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(vaccineName),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: InkWell(
                                        onTap: () {
                                          // Same dialog on tapping status cell
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Vaccination Details'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Vaccine Name: $vaccineName'),
                                                  Text('Period: $vaccinePeriod months'),
                                                  Text('Status: ${isCompleted ? 'Completed' : 'Not Completed'}'),
                                                  Text('Lot ID: $lotId'),
                                                  Text('Name: $childName'),
                                                  Text('Location: $location'),
                                                  Text('Note: $providerNote'),
                                                  if (isCompleted) Text('Date: $vaccinationDate'),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            isCompleted ? 'Completed' : 'Not Completed',
                                            style: TextStyle(
                                              color: isCompleted ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              })
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
