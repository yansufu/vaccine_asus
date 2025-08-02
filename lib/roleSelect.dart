import 'package:flutter/material.dart';
import 'package:vaccine_app/parents/login.dart';
import 'package:vaccine_app/provider/loginProv.dart';
import 'parents/navbar.dart';
//import 'provider/loginProv.dart';

void main() => runApp(MaterialApp(
  home: roleSelect(),
  debugShowCheckedModeBanner: false,
));

class roleSelect extends StatelessWidget {
  const roleSelect({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 25,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: screenHeight * 0.3,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Images/image.png'),
                fit: BoxFit.cover, 
              ),
            ),
            child: Text("Ibu Digi",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFFFC0DA),
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
              ),
            ),
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 15,),
              Text("Ibu",
              style: TextStyle(
                color: Color(0xFFC28CA5),
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                fontSize: 25,
              ),),
              SizedBox(width: 8,),
              Text("Digi",
                style: TextStyle(
                  color: Color(0xFFFFC0DA),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  fontSize: 25,
                ),),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 15,),
              Text("Powered by Posyandu",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF877777),
              ),)
            ],
          ),
          SizedBox(height: screenHeight * 0.08,),
          Text("I am a ...",
          style: TextStyle(
            color: Color(0xFF877777),
            fontWeight: FontWeight.bold,
          ),),
          SizedBox(height:screenHeight * 0.05,),
          Container(
            margin: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginParents()),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 15.0),
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: BorderSide.strokeAlignOutside,
                              offset: Offset(0, 0.5),
                            )
                          ],
                        ),
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Image.asset('assets/Images/parents_logo.png'),
                        ),
                      ),
                      const Text(
                        "Parents",
                        style: TextStyle(
                          color: Color(0xFF877777),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginProv()),
                    );
                  },
                child: Column(
                    children: [
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 15.0),
                          padding: const EdgeInsets.all(20),
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
                          child:SizedBox(
                            height: 80,
                            width: 80,
                            child:Image.asset('assets/Images/provider_logo.png'),
                          )
                      ),
                      Text("Provider",
                        style: TextStyle(
                          color: Color(0xFF877777),
                          fontWeight: FontWeight.bold,
                        ),)
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}