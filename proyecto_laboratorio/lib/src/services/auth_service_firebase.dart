import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:proyecto_laboratorio/src/repositories/auth_repository.dart';
import 'package:proyecto_laboratorio/src/services/api_service.dart';

class AuthServiceFirebase implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    String res = 'Something went wrong';

    try {
      if (kDebugMode) {
        print("--> Intentando iniciar sesión con: $email");
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print("--> Inicio de sesión exitoso");
      }

      return 'Success';
    } on FirebaseAuthException catch (error) {
      if (kDebugMode) {
        print("--> FirebaseAuthException: [${error.code}] ${error.message}");
      }

      switch (error.code) {
        case 'user-not-found':
          res = 'Usuario no encontrado';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          res = 'Credenciales inválidas (correo o contraseña incorrectos)';
          break;
        case 'invalid-email':
          res = 'El formato del correo electrónico es inválido';
          break;
        case 'user-disabled':
          res = 'Esta cuenta ha sido deshabilitada';
          break;
        case 'too-many-requests':
          res = 'Demasiados intentos fallidos. Intenta más tarde';
          break;
        case 'network-request-failed':
          res = 'Error de red: verifica la conexión a internet de tu emulador';
          break;
        default:
          res = error.message ?? error.code;
          break;
      }
    } catch (error) {
      if (kDebugMode) {
        print("--> Error general inesperado: $error");
      }
      res = error.toString();
    }

    return res;
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    String res = 'Something went wrong';

    try {
      final user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      res = 'Success';
      await ApiService.actualizarPerfil(nombre: name);

      // Guardar el perfil del usuario en Firestore
      final String? uid = user.user?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'name': name,
          'email': email,
          'phone': '',
          'creationDate': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (error) {
      if (error.code == 'weak-password') {
        res = 'La contraseña proporcionada es demasiado débil';
      } else if (error.code == 'email-already-in-use') {
        res = 'Ya existe una cuenta con ese correo electrónico';
      } else if (error.code == 'invalid-email') {
        res = 'El formato del correo electrónico es inválido';
      } else if (error.code == 'network-request-failed') {
        res = 'Error de red: verifica tu conexión a internet';
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
    }

    return res;
  }

  // Envía un correo para restablecer la contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'invalid-email':
          throw 'El formato del correo electrónico es inválido';
        case 'user-not-found':
          throw 'No se encontró un usuario con ese correo';
        case 'too-many-requests':
          throw 'Demasiados intentos. Intenta más tarde';
        case 'network-request-failed':
          throw 'Error de conexión. Revisa tu internet';
        default:
          throw 'Error al enviar el correo';
      }
    } catch (error) {
      throw 'Error inesperado: $error';
    }
  }
}
