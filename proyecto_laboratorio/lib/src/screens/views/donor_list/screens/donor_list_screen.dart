import 'package:flutter/material.dart';

import '../../../../general/config/colors.dart';
import '../../../../general/utils/blank_space.dart';
import '../../../../general/utils/contact.dart';
import '../../../../general/utils/formatters.dart';
import '../../../../general/utils/responsive.dart';
import '../../../../services/api_service.dart';
import '../../components/widgets/custom_appbar.dart';
import '../../components/widgets/custom_blood_filter_box.dart';

/// Lista de donantes registrados, con filtro por grupo sanguíneo y ubicación.
class DonorListScreen extends StatefulWidget {
  static const pageRoute = '/donor-list';

  /// Grupo con el que se abre la lista (null = todos)
  final String? grupo;

  const DonorListScreen({super.key, this.grupo});

  @override
  State<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  final _location = TextEditingController();
  List<Map<String, dynamic>> _donors = [];
  String? _grupo;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _grupo = widget.grupo;
    _cargar();
  }

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lista = await ApiService.buscarDonantes(
        grupo: _grupo,
        ubicacion: _location.text,
      );
      if (!mounted) return;
      setState(() {
        _donors = lista;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  Widget _tarjeta(BuildContext context, Map<String, dynamic> d) {
    final telefono = valueOrDash(d['telefono']);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: twentyPixelHeight(context)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.whiteColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: twentyPixelWidth(context) * 1.9,
            height: twentyPixelWidth(context) * 1.9,
            decoration: const ShapeDecoration(
              color: AppColor.redColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
            child: Center(
              child: Text(
                valueOrDash(d['grupo_sanguineo']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          horizontalSpace(twentyPixelWidth(context) * .5),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: twentyPixelHeight(context) * .4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valueOrDash(d['nombre']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColor.blackColor,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    valueOrDash(d['ubicacion']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColor.textAss,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'Last donation: ${formatDate(d['ultima_donacion'])}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColor.textAss,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    telefono,
                    style: const TextStyle(
                      color: AppColor.blackColor,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Call',
            onPressed: () => openContact(context, 'tel', telefono),
            icon: const Icon(Icons.call, color: AppColor.redColor),
          ),
        ],
      ),
    );
  }

  Widget _contenido(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: AppColor.redColor)),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColor.redColor)),
        ),
      );
    }
    if (_donors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No donors found', style: TextStyle(color: AppColor.textAss)),
        ),
      );
    }
    return Column(children: [for (final d in _donors) _tarjeta(context, d)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titlee: "Available Donors", actionTrue: true),
      body: RefreshIndicator(
        color: AppColor.redColor,
        onRefresh: _cargar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: twentyPixelWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(twentyPixelHeight(context)),
                CustomBloodFilterBox(
                  initialValue: widget.grupo,
                  onChanged: (g) {
                    _grupo = g;
                    _cargar();
                  },
                ),
                verticalSpace(twentyPixelHeight(context) * .5),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _location,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _cargar(),
                        decoration: const InputDecoration(
                          hintText: 'Filter by location (optional)',
                          prefixIcon: Icon(Icons.location_on),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _cargar,
                      icon: const Icon(Icons.search, color: AppColor.redColor),
                    ),
                  ],
                ),
                verticalSpace(twentyPixelHeight(context)),
                _contenido(context),
                verticalSpace(twentyPixelHeight(context) * 1.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
