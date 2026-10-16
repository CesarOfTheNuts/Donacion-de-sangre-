import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'formatters.dart';

/// scheme: 'tel' (llamar) o 'sms' (mensaje)
Future<void> openContact(BuildContext context, String scheme, String number) async {
  var ok = false;
  try {
    ok = await launchUrl(Uri(scheme: scheme, path: number),
        mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok && context.mounted) {
    showMsg(context, 'No se pudo abrir la aplicación. Número: $number', error: true);
  }
}
