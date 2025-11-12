import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:flutter/material.dart';

class DemMessage extends StatefulWidget {
  const DemMessage({super.key});

  @override
  State<DemMessage> createState() => _DemMessageState();
}

class _DemMessageState extends State<DemMessage> {
  ConstColors colors = ConstColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(slivers: [Header(auto: false)]),
    );
  }
}
