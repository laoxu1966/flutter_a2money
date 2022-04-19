import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:permission_handler/permission_handler.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key, required this.slides}) : super(key: key);
  final List<Slide> slides;
  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
  }

  void onDonePress() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/home', (router) => false);
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      size: 30,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: widget.slides,
      colorActiveDot: Theme.of(context).colorScheme.secondary,
      colorDot: Colors.grey,
      renderSkipBtn: Container(),
      renderNextBtn: Container(),
      renderDoneBtn: renderDoneBtn(),
      onDonePress: onDonePress,
    );
  }
}
