import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../my/my.page.dart';
import '../ability/abilities.page.dart';
import '../question/questions.page.dart';

import 'search.page.dart';
import 'drawer.page.dart';
import 'classificationtag.page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  late List<StatefulWidget> pages;
  PageController? pageController;

  @override
  void initState() {
    super.initState();

    pages = <StatefulWidget>[
      const AbilitysPage(
        path: '/ability/findAll',
        params: {'paying': 0},
      ),
      const AbilitysPage(
        path: '/ability/findAll',
        params: {'paying': 1},
      ),
      const QuestionsPage(
        path: '/question/findAll',
        params: {},
      ),
      const MyPage(),
    ];

    currentIndex = 0;
    pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        drawer: const DrawerPage(),
        appBar: AppBar(
          title: const Text('能力变现平台'),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search, size: 27),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz, size: 27),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClassificationTagPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: PageView.builder(
          itemBuilder: (BuildContext context, int index) {
            return pages[index];
          },
          controller: pageController,
          itemCount: pages.length,
          onPageChanged: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(MaterialCommunityIcons.key_plus),
              label: '能力供给',
            ),
            BottomNavigationBarItem(
              icon: Icon(MaterialCommunityIcons.key_minus),
              label: '能力需求',
            ),
            BottomNavigationBarItem(
              icon: Icon(MaterialIcons.question_answer),
              label: '能力知乎',
            ),
            BottomNavigationBarItem(
              icon: Icon(MaterialIcons.person),
              label: '我的',
            ),
          ],
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          onTap: (int index) {
            setState(() {
              currentIndex = index;
              pageController!.jumpToPage(currentIndex);
            });
          },
        ),
      ),
    );
  }
}
