import 'package:flutter/material.dart';
import 'package:flutter_otp_kit/flutter_otp_kit.dart';
import 'package:proyecto_laboratorio/src/screens/views/auth/recovery_screen.dart';

class OtpRecoveryScreen extends StatefulWidget {
  final String email;

  const OtpRecoveryScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpRecoveryScreen> createState() => _OtpRecoveryScreenState();
}

class _OtpRecoveryScreenState extends State<OtpRecoveryScreen> {
  // Función para validar el código contra el backend/servicio
  Future<bool> _verifyOtpWithBackend(String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    // Valida que el código no esté vacío y tenga al menos 4 dígitos
    return otp.trim().isNotEmpty && otp.trim().length >= 4;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: OtpKit(
            title: 'Código de Verificación',
            subtitle: 'Ingresa los dígitos enviados a:\n${widget.email}',
            fieldCount: 4,
            titleStyle: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
            onVerify: (otp) async {
              final isValid = await _verifyOtpWithBackend(otp);

              if (isValid && mounted) {
                // Navega al paso 3: Ingreso de la nueva contraseña
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecoveryScreen(),
                  ),
                );
              }
              return isValid;
            },
            onResend: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se ha reenviado un nuevo código a tu correo'),
                  backgroundColor: Colors.black87,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}