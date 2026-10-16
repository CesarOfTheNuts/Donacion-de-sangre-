import 'package:flutter/material.dart';
import '../../../../general/config/colors.dart';
import '../../../../general/utils/blank_space.dart';
import '../../../../general/utils/contact.dart';
import '../../../../general/utils/formatters.dart';
import '../../../../general/utils/responsive.dart';
import '../../../../services/api_service.dart';
import '../../components/widgets/custom_appbar.dart';
import '../../components/widgets/custom_red_btn.dart';
import '../widgets/custom_call_btn.dart';
import '../widgets/request_details_item.dart';

class RequestDetailsScreen extends StatefulWidget {
  static const pageRoute = "/request-details-screen";
  const RequestDetailsScreen({super.key});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  Map<String, dynamic>? _s; // la solicitud (llega como argumento de la ruta)
  int? _myId;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_s == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _s = Map<String, dynamic>.from(args);
        _cargarMiId();
      }
    }
  }

  Future<void> _cargarMiId() async {
    try {
      final perfil = await ApiService.miPerfil();
      if (!mounted) return;
      setState(() => _myId = perfil['id'] as int?);
    } catch (_) {
      // Sin esto solo se oculta el botón de "marcar como cubierta"
    }
  }

  Future<void> _cambiarEstado(String estado) async {
    setState(() => _busy = true);
    try {
      final actualizada =
          await ApiService.cambiarEstadoSolicitud(_s!['id'] as int, estado);
      if (!mounted) return;
      setState(() {
        _s = actualizada;
        _busy = false;
      });
      showMsg(context, 'Request updated');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      showMsg(context, errorText(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    if (s == null) {
      return const Scaffold(
        appBar: CustomAppBar(titlee: "Details", actionTrue: true),
        body: Center(child: Text('Request not found')),
      );
    }

    final telefono = valueOrDash(s['telefono']);
    final esMia = _myId != null && _myId == s['usuario_id'];
    final abierta = s['estado'] == 'Abierta';

    return Scaffold(
      appBar: const CustomAppBar(
        titlee: "Details",
        actionTrue: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: twentyPixelWidth(context),
            right: twentyPixelWidth(context),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(twentyPixelHeight(context) * 1.5),
              RequestDetailsItem(
                titlee: "Blood want before",
                textt: formatDate(s['fecha_limite']),
              ),
              RequestDetailsItem(
                titlee: "Patient Name",
                textt: valueOrDash(s['paciente']),
              ),
              RequestDetailsItem(
                titlee: "Location ",
                textt: valueOrDash(s['ubicacion']),
              ),
              RequestDetailsItem(
                titlee: "Blood Group",
                textt: valueOrDash(s['grupo_sanguineo']),
              ),
              RequestDetailsItem(
                titlee: "Contact Number",
                textt: telefono,
              ),
              RequestDetailsItem(
                titlee: "Emergency Contact",
                textt: valueOrDash(s['telefono_emergencia']),
              ),
              RequestDetailsItem(
                titlee: "Cause",
                textt: valueOrDash(s['causa']),
              ),
              RequestDetailsItem(
                titlee: "Number of Bags",
                textt: '${s['bolsas']} Bags',
              ),
              RequestDetailsItem(
                titlee: "Others",
                textt: valueOrDash(s['otros']),
              ),
              RequestDetailsItem(
                titlee: "Status",
                textt: valueOrDash(s['estado']),
              ),
              verticalSpace(twentyPixelHeight(context)),
              CustomCallButton(
                textt: "Call",
                textColor: AppColor.whiteColor,
                fillColor: AppColor.redColor,
                borderClr: Colors.transparent,
                onTap: () => openContact(context, 'tel', telefono),
              ),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomCallButton(
                textt: "Message",
                textColor: AppColor.redColor,
                fillColor: AppColor.whiteColor,
                onTap: () => openContact(context, 'sms', telefono),
              ),
              if (esMia && abierta) ...[
                verticalSpace(twentyPixelHeight(context) * .5),
                CustomRedBtn(
                  textt: "Mark as fulfilled",
                  textColor: AppColor.redColor,
                  fillColor: AppColor.whiteColor,
                  loading: _busy,
                  onTap: () => _cambiarEstado('Cubierta'),
                ),
              ],
              verticalSpace(twentyPixelHeight(context) * 1.5),
            ],
          ),
        ),
      ),
    );
  }
}
