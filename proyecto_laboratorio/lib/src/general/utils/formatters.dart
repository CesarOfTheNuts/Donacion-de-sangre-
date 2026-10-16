import 'package:flutter/material.dart';
import '../config/colors.dart';

const _meses = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

DateTime? _parse(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

/// "2026-10-14T00:00:00.000Z" -> "14 October 2026".
/// Las fechas llegan a medianoche UTC: se usan sus componentes tal cual para no correr un día.
String formatDate(dynamic v) {
  final d = _parse(v);
  if (d == null) return '-';
  return '${d.day} ${_meses[d.month - 1]} ${d.year}';
}

/// "hace cuánto" a partir de una fecha UTC del backend.
String timeAgo(dynamic v) {
  final d = _parse(v);
  if (d == null) return '';
  final diff = DateTime.now().toUtc().difference(d.toUtc());
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 30) return '${diff.inDays} d ago';
  return formatDate(v);
}

/// DateTime -> "2026-10-14" (lo que espera el backend)
String dateToApi(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String valueOrDash(dynamic v) {
  final s = v?.toString().trim() ?? '';
  return s.isEmpty ? '-' : s;
}

String errorText(Object e) => e is String ? e : e.toString();

void showMsg(BuildContext context, String text, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: error ? AppColor.redColor : Colors.green.shade700,
    ));
}
