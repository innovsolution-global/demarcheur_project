import 'package:demarcheur_app/models/house_model.dart';
import 'package:flutter/material.dart';

class ImmoDetailPage extends StatefulWidget {
  final HouseModel house;
  const ImmoDetailPage({super.key, required this.house});

  @override
  State<ImmoDetailPage> createState() => _ImmoDetailPageState();
}

class _ImmoDetailPageState extends State<ImmoDetailPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}