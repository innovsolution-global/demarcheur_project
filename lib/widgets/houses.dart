import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HousePage extends StatefulWidget {
  final HouseModel houseModel;
  final HouseProvider houseLenth;
  const HousePage({super.key, required this.houseModel, required this.houseLenth});

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  final PageController _controller = PageController();
  ConstColors colors = ConstColors();
  int currentPage = 0;
  bool isLoading = true;
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[100]!,
              highlightColor: Colors.grey[50]!,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      "https://tse1.mm.bing.net/th/id/OIP.qeFxyzYn2vv3qIDbfH-eFQHaE8?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3",
                    ),
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              alignment: AlignmentGeometry.bottomCenter,
              children: [
                PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.houseLenth.allhouses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              widget.houseModel.imageUrl.length.toString(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.houseLenth.allhouses.length, (
                    index,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: currentPage == index ? 20 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: currentPage == index
                              ? colors.primary
                              : colors.bgSubmit,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 50),
              ],
            ),
          );
  }
}
