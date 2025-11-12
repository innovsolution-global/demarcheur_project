import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/page_content.dart';
import 'package:flutter/material.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;
  ConstColors colors = ConstColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: colors.primary,
      body: Stack(
        alignment: AlignmentGeometry.bottomCenter,
        children: [
          PageView(
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            controller: _controller,
            children: [
              PageWidget(
                text:
                    """Trouver votre travail de reve et vos services immobilies en un clique""",
                url:
                    "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
              ),
              PageWidget(
                text:
                    """Trouver votre travail de reve et vos services immobilies en un clique""",
                url:
                    "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
              ),
              PageWidget(
                text:
                    """Trouver votre travail de reve et vos services immobilies en un clique""",
                url:
                    "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    color: _currentPage == index ? colors.tertiary : colors.bg,
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.all(10),
                    duration: Duration(microseconds: 300),
                  );
                }),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text("Commencer"),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


