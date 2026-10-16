import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final GlobalKey<IntroductionScreenState> _introKey =
  GlobalKey<IntroductionScreenState>();

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.black54,
        height: 1.4,
      ),
      bodyPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.only(top: 24),
      contentMargin: EdgeInsets.symmetric(horizontal: 16),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: IntroductionScreen(
        key: _introKey,
        globalBackgroundColor: Colors.white,
        pages: [
          PageViewModel(
            title: "Salva Vidas",
            body: "Conéctate de manera rápida y eficiente con quienes más lo necesitan en momentos críticos.",
            image: Center(
              child: Image.asset(
                'assets/images/save_lives.png',
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Totalmente Seguro",
            body: "Tus datos y registros médicos cuentan con la mayor protección y privacidad en todo momento.",
            image: Center(
              child: Image.asset(
                'assets/images/secure.png',
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Fácil de Usar",
            body: "Una interfaz intuitiva pensada para brindarte una respuesta ágil sin complicaciones.",
            image: Center(
              child: Image.asset(
                'assets/images/easy.png',
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            decoration: pageDecoration,
            footer: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                onPressed: () => _goToLogin(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "¡Empecemos!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ],
        onDone: () => _goToLogin(context),
        onSkip: () => _goToLogin(context),
        showSkipButton: true,
        showNextButton: true,
        showDoneButton: false,
        showBackButton: false,
        skip: const Text(
          "Saltar",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        next: const Icon(Icons.arrow_forward),
        done: const Text(
          "Listo",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        skipStyle: TextButton.styleFrom(foregroundColor: Colors.grey),
        nextStyle: TextButton.styleFrom(foregroundColor: theme.primaryColor),
        dotsDecorator: DotsDecorator(
          size: const Size.square(9),
          activeSize: const Size(22, 9),
          activeColor: theme.primaryColor,
          color: Colors.black12,
          spacing: const EdgeInsets.symmetric(horizontal: 4),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}