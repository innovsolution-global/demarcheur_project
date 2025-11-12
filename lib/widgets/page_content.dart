import 'package:flutter/material.dart';

class PageWidget extends StatelessWidget {
  final String text;
  final String url;
  const PageWidget({super.key, required this.text, required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Image.network(url, fit: BoxFit.cover)),
        Positioned.fill(
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Text(
                textAlign: TextAlign.center,
                text,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
