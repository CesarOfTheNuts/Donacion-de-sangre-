import 'dart:async';

import 'package:flutter/material.dart';
import 'package:proyecto_laboratorio/src/screens/views/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initstate
    super.initState();
    Timer (Duration(seconds: 3),()  {
      Navigator.pushReplacement(context , MaterialPageRoute(builder: (context) => OnboardingScreen(), ));
    },);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(image: AssetImage('assets/images/splash.png'),
              fit: BoxFit.cover,
              opacity: 0.6,
            )
        ),
      ),
    );
  }
}
