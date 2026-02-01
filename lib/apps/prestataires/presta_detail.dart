import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/presta/presta_model.dart';
import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/widgets/btn.dart';
import 'package:demarcheur_app/widgets/chat_widget.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class PrestaDetail extends StatefulWidget {
  final PrestaModel presta;
  const PrestaDetail({super.key, required this.presta});

  @override
  State<PrestaDetail> createState() => _PrestaDetailState();
}

class _PrestaDetailState extends State<PrestaDetail> {
  ConstColors color = ConstColors();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.bg,
      body: CustomScrollView(
        slivers: [
          Header(auto: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCard(color: color, presta: widget.presta),

                  SizedBox(height: 16),
                  //Divider(height: 25, color: color.tertiary),
                  _SectionChips(
                    color: color,
                    selectedIndex: selectedIndex,
                    onSelect: (i) => setState(() => selectedIndex = i),
                  ),
                  // SizedBox(height: 8),
                  content(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: Btn(
                  texte: "Contacter",
                  function: () {
                    final authProvider = context.read<AuthProvider>();
                    final myId = authProvider.userId;
                    if (myId == null) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Connectez-vous pour envoyer un message")),
                       );
                       return;
                    }
                    
                    final receiverId = widget.presta.ownerId ?? widget.presta.id ?? '';
                    if (receiverId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("ID du destinataire introuvable")),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatWidget(
                          pageType: 'Presta',
                          message: SendMessageModel(
                            senderId: myId,
                            receiverId: receiverId,
                            userName: widget.presta.companyName,
                            userPhoto: widget.presta.imageUrl.isNotEmpty ? widget.presta.imageUrl.first : null,
                            content: '',
                            timestamp: DateTime.now(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menu(String label, int index) {
    bool selected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        height: 37,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? color.primary : color.bg,
          border: Border.all(color: color.primary),
        ),
        child: SubTitle(
          text: label,
          fontWeight: FontWeight.w500,
          color: selected ? color.bg : color.primary,
        ),
      ),
    );
  }

  Widget content() {
    if (selectedIndex == 0) {
      return Column(
        children: widget.presta.exigences
            .map(
              (ex) => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.bgSubmit,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: color.accepted, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ex,
                        style: TextStyle(color: color.primary, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    } else if (selectedIndex == 1) {
      return Column(
        children: [
          SizedBox(height: 4),
          Text(
            maxLines: 2,
            "Nous sommes situe a ${widget.presta.location}",
            style: TextStyle(color: color.primary, fontSize: 16),
          ),
        ],
      );
    } else if (selectedIndex == 2) {
      return Column(
        children: [
          SizedBox(height: 4),
          Text(
            maxLines: 2,
            widget.presta.salary == "A negocier"
                ? "Le salaire est a negocie"
                : "Nous proposons ${widget.presta.salary}",
            style: TextStyle(color: color.primary, fontSize: 16),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          SizedBox(height: 4),
          Text(
            maxLines: 2,
            widget.presta.about,
            style: TextStyle(color: color.primary, fontSize: 16),
          ),
        ],
      );
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final ConstColors color;
  final PrestaModel presta;
  const _HeaderCard({required this.color, required this.presta});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                presta.imageUrl.first,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleWidget(
                    text: presta.title,
                    fontSize: 18,
                    color: color.primary,
                  ),
                  SubTitle(
                    text: presta.companyName,
                    fontsize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: color.primary,
                      ),
                      SizedBox(width: 4),
                      SubTitle(text: presta.location, fontsize: 14),
                      SizedBox(width: 12),
                      Icon(Icons.schedule, size: 16, color: color.primary),
                      SizedBox(width: 4),
                      SubTitle(text: presta.postDate, fontsize: 12),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: 4.0,
                        itemBuilder: (context, index) =>
                            Icon(Icons.star, color: color.impression),
                        itemCount: 5,
                        itemSize: 18.0,
                        direction: Axis.horizontal,
                      ),
                      SizedBox(width: 8),
                      SubTitle(text: "(4.0)", fontsize: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionChips extends StatelessWidget {
  final ConstColors color;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _SectionChips({
    required this.color,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final labels = const ["Exigences", "Localisation", "Salaire", "Apropos"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSel = selectedIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(labels[index]),
              selected: isSel,
              onSelected: (_) => onSelect(index),
              selectedColor: color.primary,
              backgroundColor: color.bg,
              labelStyle: TextStyle(
                color: isSel ? color.bg : color.primary,
                fontWeight: FontWeight.w600,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSel ? Colors.transparent : color.primary,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }),
      ),
    );
  }
}
