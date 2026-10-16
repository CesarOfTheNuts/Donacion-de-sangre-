import 'package:flutter/material.dart';
import 'package:proyecto_laboratorio/src/screens/views/onboarding/splash_screen.dart';
import 'package:proyecto_laboratorio/src/screens/views/all_request_details/screens/request_details_screen.dart';
import 'package:proyecto_laboratorio/src/screens/views/all_requests/screens/all_request_screen.dart';
import 'package:proyecto_laboratorio/src/screens/views/donor_registration/screens/donor_registration_screen.dart';
import 'package:proyecto_laboratorio/src/screens/views/find_donor/screens/find_donor_screen.dart';
import 'package:proyecto_laboratorio/src/screens/views/home/screens/home_screen.dart';
import 'package:proyecto_laboratorio/src/screens/views/profile/screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//CONTRASE;A PROFE
//INTEC2026!

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xffd32f2f),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
      // Rutas con nombre usadas por las pantallas del home (Navigator.pushNamed)
      routes: {
        HomeScreen.pageRoute: (context) => const HomeScreen(),
        ProfileScreen.pageRoute: (context) => const ProfileScreen(),
        DonorRegistrationForm.pageRoute: (context) => const DonorRegistrationForm(),
        FindDonorScreen.pageRoute: (context) => const FindDonorScreen(),
        AllRequestScreen.pageRoute: (context) => const AllRequestScreen(),
        RequestDetailsScreen.pageRoute: (context) => const RequestDetailsScreen(),
      },
    );
  }
}
