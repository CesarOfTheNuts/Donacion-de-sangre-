import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_laboratorio/src/constants/validators.dart';
import 'package:proyecto_laboratorio/src/screens/views/components/widgets/main_button.dart';
import 'package:proyecto_laboratorio/src/screens/views/auth/otp_recovery_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode() async {
    // 1. Validar que el correo tenga formato correcto
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulación de envío del código al correo
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // 2. Navegar a la pantalla del OTP pasando el correo ingresado
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpRecoveryScreen(
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Por favor, ingresa tu correo electrónico. Te enviaremos un código de verificación para restablecer tu contraseña.',
                  style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: emailValidator.call,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(CupertinoIcons.clear),
                      onPressed: () => _emailController.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                MainButton(
                  label: "SEND",
                  isLoading: _isLoading,
                  action: _sendCode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}