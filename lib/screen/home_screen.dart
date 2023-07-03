import 'dart:math';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
const  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late Animation<double> animation;
  late AnimationController controller;
  bool status = false;
  double led1Value = 0;
  double led2Value = 0;
  double slidervalue = 0;
  Color led1Color = Colors.grey;
  Color led2Color = Colors.grey;
  int bulbIndex = 0;
  double guageValue = 0;
  @override
  void initState() {

    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    controller.addStatusListener(((status) async {
      if (status == AnimationStatus.completed) {
        controller.repeat();
      }
    }));
    setRotation(360);
    getFanOnOff();
    getBulbStatus();
    getBulbValue();
    getGuageValue();
  }

  @override
  void dispose() {
   
    controller.dispose();
    super.dispose();
  }

  void setRotation(int degrees) {
    final angle = degrees * pi / 180;
    animation = Tween<double>(begin: 0, end: angle).animate(controller);
  }

  void setBulbColor(double value) {
    setState(() {
      if (value == 0) {
        led1Color = Colors.grey;
      } else if (value <= 200 && value > 0) {
        led1Color = Colors.yellow.shade200;
      } else if (value <= 400 && value > 200) {
        led1Color = Colors.yellow.shade400;
      } else if (value <= 600 && value > 400) {
        led1Color = Colors.yellow.shade600;
      } else if (value <= 800 && value > 600) {
        led1Color = Colors.yellow.shade800;
      } else if (value <= 1023 && value > 800) {
        led1Color = Colors.yellow.shade900;
      }
    });
  }

  void getGuageValue() async {
    final ref = database.ref();
    await ref.child('id/pot').onValue.listen((event) {
      var snapshot = event.snapshot;

      setState(() {
        guageValue = double.parse(snapshot.value.toString());
      });
    });
  }

  void getFanOnOff() async {
    final ref = database.ref();
    await ref.child('id/fan').onValue.listen((event) {
      var snapshot = event.snapshot;

      if (snapshot.exists) {
       
        if (snapshot.value == 0) {
          setState(() {
            status = false;
            controller.stop();
          });
        } else {
          setState(() {
            status = true;
            controller.forward(from: 0);
          });
        }
      } else {
        
      }
    });
  }

  void getBulbValue() async {
    final ref = database.ref();
    await ref.child('id/led2').onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.exists) {
      
        setState(() {
          led1Value = double.parse((snapshot.value).toString());
          setBulbColor(led1Value);
        });
      } else {
      
      }
    });
  }

  void getBulbStatus() async {
    final ref = database.ref();
    await ref.child('id/led1').onValue.listen((event) {
      var snapshot = event.snapshot;

      if (snapshot.exists) {
        
        if (snapshot.value == 0) {
          setState(() {
            bulbIndex = 0;
          });
        } else {
          setState(() {
            bulbIndex = 1;
          });
        }
      } else {
       
      }
    });
  }

  void fanControl(int num) async {
    DatabaseReference ref = database.ref("id");
    await ref.update({
      "fan": num,
    });
  }

  void buldOnOff(int? num) async {
    DatabaseReference ref = database.ref("id");
    await ref.update({
      "led1": num,
    });
  }

  void bulbControl(int num) async {
    DatabaseReference ref = database.ref("id");
    await ref.update({
      "led2": num,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: appBar(),
        ),
        backgroundColor: Colors.blue.shade100,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              facControl(context),
              bulbControlWidget(context),
              gaugeControl(context),
            ],
          ),
        ),
      ),
    );
  }

  Expanded gaugeControl(BuildContext context) {
    return Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(vertical: 10),
                height: 200,
                width: MediaQuery.of(context).size.width - 40,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: SizedBox(
                    height: 230,
                    child: SfRadialGauge(axes: <RadialAxis>[
                      RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          ranges: <GaugeRange>[
                            GaugeRange(
                                startValue: 0,
                                endValue: 33.3,
                                color: Colors.green),
                            GaugeRange(
                                startValue: 33.3,
                                endValue: 66.6,
                                color: Colors.orange),
                            GaugeRange(
                                startValue: 66.6,
                                endValue: 100,
                                color: Colors.red)
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(value: guageValue)
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                                widget: Text('$guageValue',
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold)),
                                angle: 90,
                                positionFactor: 0.5)
                          ])
                    ])),
              ),
            );
  }

  Padding bulbControlWidget(BuildContext context) {
    return Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 10),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  const Offset(0, 3), 
                            ),
                          ],
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/bulb2.svg',
                            color: led1Color,
                            height: 80,
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.green,
                              thumbColor: Colors.green,
                              trackHeight: 5.0,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 13.0),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 28.0),
                            ),
                            child: Slider(
                              value: led1Value,
                              onChanged: ((value) {
                                setState(() {
                                  led1Value = value;
                                  setBulbColor(value);
                                });

                                bulbControl(value.toInt());
                              }),
                              max: 1023,
                              min: 0,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 155,
                      margin: const EdgeInsets.only(left: 10, right: 20),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ToggleSwitch(
                            minWidth: 60.0,
                            minHeight: 60.0,
                            initialLabelIndex: bulbIndex,
                            cornerRadius: 20.0,
                            activeFgColor: Colors.white,
                            inactiveBgColor: Colors.grey,
                            inactiveFgColor: Colors.white,
                            totalSwitches: 2,
                            icons: const [
                              FontAwesomeIcons.lightbulb,
                              FontAwesomeIcons.solidLightbulb,
                            ],
                            iconSize: 30.0,
                            activeBgColors: const [
                              [Colors.black45, Colors.black26],
                              [Colors.yellow, Colors.orange]
                            ],
                            // animate:
                            //     true, // with just animate set to true, default curve = Curves.easeIn
                            curve: Curves
                                .bounceInOut, // animate must be set to true when using custom curve
                            onToggle: (index) {
                              buldOnOff(index);
                              bulbIndex = index!;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
  }

  Container facControl(BuildContext context) {
    return Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              margin: const EdgeInsets.only(top: 20, bottom: 30),
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: animation,
                    builder: ((context, child) {
                      return Transform.rotate(
                          angle: animation.value, child: child);
                    }),
                    child: Image.asset(
                      'assets/fan.png',
                      height: 140,
                      width: 140,
                    ),
                  ),
                  // ElevatedButton(
                  //     onPressed: () {
                  //       setRotation(360);
                  //       controller.forward(from: 0);
                  //     },
                  //     child: Text('')),
                  const SizedBox(
                    width: 40,
                  ),
                  FlutterSwitch(
                    activeColor: Colors.green,
                    width: 90.0,
                    height: 40.0,
                    valueFontSize: 20.0,
                    toggleSize: 35.0,
                    value: status,
                    borderRadius: 30.0,
                    padding: 8.0,
                    showOnOff: true,
                    onToggle: (val) {
                      setState(() {
                        status = val;
                        if (val == true) {
                          setRotation(360);
                          controller.forward(from: 0);
                          fanControl(1);
                        } else {
                          controller.stop();
                          fanControl(0);
                        }
                      });
                    },
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                ],
              ),
            );
  }

  AppBar appBar() {
    return AppBar(
          leading: const Icon(Icons.menu),
          backgroundColor: Colors.blue.shade400,
          centerTitle: true,
          title: Text(
            "Galapathaya ESP32",
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                  color: Colors.white,
                  letterSpacing: .5,
                  fontWeight: FontWeight.bold,
                  fontSize: 23),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        );
  }
}
