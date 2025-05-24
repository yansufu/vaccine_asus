import 'package:flutter/material.dart';
import 'navbar.dart';

class HomeParent extends StatefulWidget {
  const HomeParent({super.key});

  @override
  State<HomeParent> createState() => _HomeParentState();
}

class _HomeParentState extends State<HomeParent> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Parent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFFBBE0)),
        useMaterial3: true,
      ),
      home: const NavBar_screen(),
    );
  }
}

class homeScreen extends StatelessWidget {
  const homeScreen({super.key});

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
      body: SingleChildScrollView(
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
                      children: const [
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
                              "Posyandu Jambangan, Candi Sidoarjo",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Annisa Delicia Yansaf",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "4 months, 24 days",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text("Hepatitis",
                                  style: TextStyle(color: Colors.grey),),
                                SizedBox(height: 5.0),
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.lightGreenAccent,
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text("Polio",
                                  style: TextStyle(color: Colors.grey),),
                                SizedBox(height: 5.0),
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.lightGreenAccent,
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text("HIB",
                                  style: TextStyle(color: Colors.grey),),
                                SizedBox(height: 5.0),
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.lightGreenAccent,
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text("DTP",
                                  style: TextStyle(color: Colors.grey),),
                                SizedBox(height: 5.0),
                                Icon(
                                  Icons.radio_button_unchecked_rounded,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ],
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
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 15),
                          child:
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(),
                              1: FlexColumnWidth(),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Color(0xFFFBF6F8)),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Name', style: TextStyle(color: Color(0xFF777777), fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              TableRow(
                                decoration: BoxDecoration(color: Colors.white),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Name', style: TextStyle(color: Color(0xFF777777), fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              TableRow(
                                decoration: BoxDecoration(color: Color(0xFFFBF6F8)),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Name', style: TextStyle(color: Color(0xFF777777), fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Completed', style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              TableRow(
                                decoration: BoxDecoration(color: Color(0xFFFBF6F8)),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Name', style: TextStyle(color: Color(0xFF777777), fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Not Completed', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              TableRow(
                                decoration: BoxDecoration(color: Colors.white),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Name', style: TextStyle(color: Color(0xFF777777), fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Not Completed', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              TableRow(
                                decoration: BoxDecoration(color: Color(0xFFFBF6F8)),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Name', style: TextStyle(color: Color(0xFF777777), fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Not Completed', style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ]
            )
          ],
        ),
      ),
    );
  }
}