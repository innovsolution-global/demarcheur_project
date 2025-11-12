import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/search_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';


class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SubmitPageState createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  ConstColors color = ConstColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.bg,

      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            actionsPadding: EdgeInsets.all(20),

            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowTurnBackward),
            ),
            iconTheme: IconThemeData(color: color.bg),
            actionsIconTheme: IconThemeData(color: color.bg),
            backgroundColor: Colors.transparent,
            title: Text(
              "Details du boulot",
              style: TextStyle(
                color: color.bg,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: color.primary,
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
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 110,
                    decoration: BoxDecoration(
                      border: Border.all(color: color.bgSubmit),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: color.bgSubmit),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  "https://tse2.mm.bing.net/th/id/OIP.HP55nAQfHY4mlb4v9MxJKAHaEK?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleWidget(text: "UI/UX Designer", fontSize: 18),
                              SubTitle(
                                text: "Google",
                                fontsize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              SubTitle(text: "il y a 10 min", fontsize: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: color.accepted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.done_sharp,
                              size: 40,
                              color: color.bg,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Succes!",
                          style: TextStyle(
                            color: color.accepted,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Votre demande a été envoyé avec succès. vous pouvez voir le status de votre demande dans la section “Demande” ",
                          style: TextStyle(
                            color: color.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const SearchPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.primary,
                  ),
                  child: TitleWidget(
                    text: 'Voir mes demandes',
                    fontSize: 16,
                    color: color.bg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
