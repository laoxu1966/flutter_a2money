import 'package:flutter/material.dart';

import 'ui.dart';

class CarouselPage extends StatefulWidget {
  final List<String> pictureUrls;
  final int index;

  @override
  const CarouselPage(this.pictureUrls, this.index, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CarouselPageState();
  }
}

class CarouselPageState extends State<CarouselPage> {
  int startX = 0;
  int endX = 0;
  int index = 0;
  List<String> pictureUrls = [];

  @override
  void initState() {
    super.initState();

    index = widget.index;
    pictureUrls = widget.pictureUrls;
  }

  void _getIndex(int delta) {
    if (delta > 51) {
      setState(() {
        index--;
        index = index.clamp(0, pictureUrls.length - 1);
      });
    } else if (delta < 51) {
      setState(() {
        index++;
        index = index.clamp(0, pictureUrls.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${index + 1}/${pictureUrls.length}'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              child: Center(
                child: getPicture(
                  pictureUrls[index].replaceAll('"', ''),
                ),
              ),
              onHorizontalDragDown: (detail) {
                startX = detail.globalPosition.dx.toInt();
              },
              onHorizontalDragUpdate: (detail) {
                endX = detail.globalPosition.dx.toInt();
              },
              onHorizontalDragEnd: (detail) {
                setState(() {
                  _getIndex(endX - startX);
                });
              },
              onHorizontalDragCancel: () {},
            ),
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  pictureUrls.length,
                  (i) => GestureDetector(
                    child: CircleAvatar(
                      radius: 3.0,
                      backgroundColor: index == i
                          ?  Theme.of(context).colorScheme.secondary
                          : Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        startX = endX = 0;
                        index = i;
                      });
                    },
                  ),
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
