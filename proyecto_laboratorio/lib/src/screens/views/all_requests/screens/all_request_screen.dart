import 'package:flutter/material.dart';

import '../../../../general/config/colors.dart';
import '../../../../general/utils/blank_space.dart';
import '../../../../general/utils/formatters.dart';
import '../../../../general/utils/responsive.dart';
import '../../../../services/api_service.dart';
import '../../components/widgets/custom_appbar.dart';
import '../../components/widgets/custom_blood_filter_box.dart';
import '../../home/widgets/request_feed_item.dart';

class AllRequestScreen extends StatefulWidget {
  static const pageRoute = "/all-request";
  const AllRequestScreen({super.key});

  @override
  State<AllRequestScreen> createState() => _AllRequestScreenState();
}

class _AllRequestScreenState extends State<AllRequestScreen> {
  List<Map<String, dynamic>> _requests = [];
  String? _grupo; // null = todos
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lista = await ApiService.listarSolicitudes(grupo: _grupo);
      if (!mounted) return;
      setState(() {
        _requests = lista;
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
    if (_requests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No requests found', style: TextStyle(color: AppColor.textAss)),
        ),
      );
    }
    return Column(
      children: [
        for (final s in _requests) ...[
          CustomRequestFeedItem(solicitud: s, onReturn: _cargar),
          verticalSpace(twentyPixelHeight(context) * 1),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titlee: "Blood Requests", actionTrue: true),
      body: RefreshIndicator(
        color: AppColor.redColor,
        onRefresh: _cargar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              left: twentyPixelWidth(context),
              right: twentyPixelWidth(context),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(twentyPixelHeight(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Filter',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'PoppinsBold',
                        fontWeight: FontWeight.w700,
                      ),
                      textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                    ),
                    horizontalSpace(twentyPixelWidth(context) * .25),
                    Image.asset(
                      "assets/icons/filter.png",
                      width: twelvePixelWidth(context) * 2,
                    ),
                  ],
                ),
                verticalSpace(twentyPixelHeight(context) * .5),
                CustomBloodFilterBox(
                  onChanged: (grupo) {
                    _grupo = grupo;
                    _cargar();
                  },
                ),
                verticalSpace(twentyPixelHeight(context) * 1),
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
