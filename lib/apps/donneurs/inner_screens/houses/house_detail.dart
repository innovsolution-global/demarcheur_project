import 'package:demarcheur_app/apps/donneurs/main_screens/jobs/message_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class DetailHouse extends StatefulWidget {
  final HouseModel house;
  final HouseProvider houseLenth;
  const DetailHouse({super.key, required this.house, required this.houseLenth});

  @override
  State<DetailHouse> createState() => _DetailHouseState();
}

class _DetailHouseState extends State<DetailHouse> {
  int currentPage = 0;
  final PageController _controller = PageController();
  ConstColors colors = ConstColors();
  final houseImage = HouseProvider();
  double rate = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            actionsPadding: EdgeInsets.all(20),

            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowTurnBackward,
                color: colors.bg,
              ),
            ),
            iconTheme: IconThemeData(color: colors.bg),
            actionsIconTheme: IconThemeData(color: colors.bg),
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: colors.primary,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 7),
                SizedBox(
                  height: 250,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _controller,
                        itemCount: widget.house.imageUrl.length,
                        onPageChanged: (index) =>
                            setState(() => currentPage = index),
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colors.tertiary),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  widget.house.imageUrl[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.house.imageUrl.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.all(4),
                            width: currentPage == index ? 20 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? colors.primary
                                  : colors.bgSubmit,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleWidget(
                    text: "Type de maison: ${widget.house.type}",
                    color: colors.primary,
                    fontSize: 18,
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SubTitle(
                        text:
                            "${NumberFormat().format(widget.house.rent)} GNF/mois",
                        fontsize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      RatingBar.builder(
                        initialRating: 1,
                        allowHalfRating: true,
                        unratedColor: Colors.grey,
                        itemSize: 25,
                        onRatingUpdate: (value) {
                          setState(() {
                            rate = value;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Icon(Icons.star, color: colors.impression);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      menu("Description", 0),
                      SizedBox(width: 10),
                      menu("Apropos", 1),
                    ],
                  ),

                  SizedBox(height: 16),
                  content(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const MessagePage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: colors.primary,
                        side: BorderSide.none,
                      ),
                      child: TitleWidget(
                        text: "Contacter",
                        color: colors.bg,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int currentIndex = 0;
  Widget menu(String label, int index) {
    bool selected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.bg,
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SubTitle(
              text: label,
              fontWeight: FontWeight.bold,
              fontsize: 16,
              color: selected ? colors.bg : colors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget content() {
    if (currentIndex == 0) {
      return SizedBox(
        height: 225,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors.bgSubmit,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bed, color: colors.primary),
                        SizedBox(width: 5),
                        SubTitle(text: "4 Chambres"),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors.bgSubmit,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bathroom, color: colors.primary),
                        SizedBox(width: 5),
                        SubTitle(text: "2 Douches"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors.bgSubmit,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.soup_kitchen, color: colors.primary),
                        SizedBox(width: 5),
                        SubTitle(text: "1 Cuisine"),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors.bgSubmit,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.balcony, color: colors.primary),
                        SizedBox(width: 5),
                        SubTitle(text: "1 Balcon"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            SubTitle(
              text:
                  "Cette maison est situee a ${widget.house.location} dans la commune de Sonfonia elle est belle et propre ",
              fontsize: 18,
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        height: 225,
        child: Column(
          children: [
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam feugiat tellus a mattis ornare. Fusce sit amet libero id est iaculis hendrerit in quis nibh. Proin porttitor velit nec purus consequat hendrerit. Aenean vel volutpat metus. Ut ullamcorper arcu tellus, non semper nisl lobortis vitae",
              style: TextStyle(fontSize: 18, color: colors.primary),
            ),
          ],
        ),
      );
    }
  }
}
