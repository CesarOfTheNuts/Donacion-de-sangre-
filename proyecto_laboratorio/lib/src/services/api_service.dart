// lib/src/services/api_service.dart
// Necesita en pubspec.yaml:  http, url_launcher  (firebase_auth ya lo tienes)
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Emulador Android -> 10.0.2.2 | Teléfono físico -> IP de tu PC (ej: 192.168.1.10)
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const Duration _timeout = Duration(seconds: 15);

  // Pide el token a Firebase (se renueva solo cuando vence) y lo manda al backend
  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Todas las llamadas pasan por aquí. Si algo falla lanza un String legible.
  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(
        queryParameters: (query == null || query.isEmpty) ? null : query,
      );
      final req = http.Request(method, uri)..headers.addAll(await _headers());
      if (body != null) req.body = jsonEncode(body);

      final r = await (() async {
        final streamed = await req.send();
        return http.Response.fromStream(streamed);
      })()
          .timeout(_timeout);

      final data = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
      if (r.statusCode >= 200 && r.statusCode < 300) return data;
      if (data is Map && data['error'] != null) throw data['error'].toString();
      throw 'Error del servidor (${r.statusCode})';
    } on TimeoutException {
      throw 'El servidor no respondió. ¿Está corriendo el backend?';
    } on SocketException {
      throw 'No se pudo conectar con el servidor. Revisa que el backend esté corriendo.';
    } on http.ClientException {
      throw 'No se pudo conectar con el servidor. Revisa que el backend esté corriendo.';
    } on FormatException {
      throw 'Respuesta inválida del servidor';
    }
  }

  // ---------- Perfil ----------
  static Future<Map<String, dynamic>> miPerfil() async =>
      Map<String, dynamic>.from(await _request('GET', '/auth/me'));

  // Solo se envían los campos que no sean null. Un texto vacío ('') borra el dato.
  static Future<Map<String, dynamic>> actualizarPerfil({
    String? nombre,
    String? telefono,
    String? ubicacion,
    String? genero,
    String? grupoSanguineo,
  }) async {
    final body = <String, dynamic>{
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (ubicacion != null) 'ubicacion': ubicacion,
      if (genero != null) 'genero': genero,
      if (grupoSanguineo != null) 'grupo_sanguineo': grupoSanguineo,
    };
    return Map<String, dynamic>.from(await _request('PUT', '/auth/me', body: body));
  }

  // ---------- Donantes ----------
  static Future<Map<String, dynamic>> crearDonante(Map<String, dynamic> d) async =>
      Map<String, dynamic>.from(await _request('POST', '/donantes', body: d));

  static Future<List<Map<String, dynamic>>> buscarDonantes({
    String? grupo,
    String? ubicacion,
  }) async {
    final data = await _request('GET', '/donantes', query: {
      if (grupo != null && grupo.isNotEmpty) 'grupo': grupo,
      if (ubicacion != null && ubicacion.trim().isNotEmpty) 'ubicacion': ubicacion.trim(),
    });
    return (data as List).cast<Map<String, dynamic>>();
  }

  // ---------- Solicitudes ----------
  static Future<Map<String, dynamic>> crearSolicitud(Map<String, dynamic> s) async =>
      Map<String, dynamic>.from(await _request('POST', '/solicitudes', body: s));

  static Future<List<Map<String, dynamic>>> listarSolicitudes({
    String? grupo,
    int? limit,
  }) async {
    final data = await _request('GET', '/solicitudes', query: {
      if (grupo != null && grupo.isNotEmpty) 'grupo': grupo,
      if (limit != null) 'limit': '$limit',
    });
    return (data as List).cast<Map<String, dynamic>>();
  }

  // estado: 'Abierta' | 'Cubierta' | 'Cancelada'  (solo el dueño de la solicitud)
  static Future<Map<String, dynamic>> cambiarEstadoSolicitud(int id, String estado) async =>
      Map<String, dynamic>.from(
          await _request('PATCH', '/solicitudes/$id/estado', body: {'estado': estado}));
}
