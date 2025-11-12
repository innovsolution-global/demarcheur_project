import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:flutter/material.dart';

class PrestaVancyPage extends StatefulWidget {
  const PrestaVancyPage({super.key});

  @override
  State<PrestaVancyPage> createState() => _PrestaVancyPageState();
}

class _PrestaVancyPageState extends State<PrestaVancyPage> {
  ConstColors colors = ConstColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(slivers: [Header(auto: false)]),
    );
  }
}
