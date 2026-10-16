import 'package:flutter/material.dart';

import '../../../../general/config/colors.dart';
import '../../../../general/utils/blank_space.dart';
import '../../../../general/utils/formatters.dart';
import '../../../../general/utils/responsive.dart';
import '../../../../services/api_service.dart';
import '../../all_request_details/widgets/request_details_item.dart';
import '../../components/widgets/custom_appbar.dart';
import '../../components/widgets/custom_red_btn.dart';
import '../../edit_profile/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const pageRoute = "/profile";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await ApiService.miPerfil();
      if (!mounted) return;
      setState(() {
        _profile = p;
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

  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile)),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile ?? const <String, dynamic>{};
    return Scaffold(
      appBar: const CustomAppBar(
        titlee: "Profile",
        actionTrue: true,
        profileFalse: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: twentyPixelWidth(context),
            vertical: twentyPixelHeight(context)),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        TextButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: twentyPixelWidth(context) * 6.5,
                              height: twentyPixelWidth(context) * 6.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                border: Border.all(color: AppColor.redColor, width: 1),
                              ),
                            ),
                            SizedBox(
                              width: twentyPixelWidth(context) * 6,
                              height: twentyPixelWidth(context) * 6,
                              child: Image.asset("assets/images/profile.png"),
                            ),
                          ],
                        ),
                      ),
                      verticalSpace(twentyPixelHeight(context) * 2),
                      RequestDetailsItem(titlee: "Name", textt: valueOrDash(p['nombre'])),
                      RequestDetailsItem(titlee: "Location", textt: valueOrDash(p['ubicacion'])),
                      RequestDetailsItem(titlee: "Gender", textt: valueOrDash(p['genero'])),
                      RequestDetailsItem(titlee: "Blood Group", textt: valueOrDash(p['grupo_sanguineo'])),
                      RequestDetailsItem(titlee: "Mobile Number", textt: valueOrDash(p['telefono'])),
                      const Expanded(child: SizedBox()),
                      CustomRedBtn(
                        textt: "Edit Profile",
                        textColor: Colors.white,
                        fillColor: AppColor.redColor,
                        borderClr: Colors.transparent,
                        onTap: _edit,
                      ),
                      verticalSpace(twentyPixelHeight(context) * .5),
                    ],
                  ),
      ),
    );
  }
}
