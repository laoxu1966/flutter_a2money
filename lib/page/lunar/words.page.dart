import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';

class WordsPage extends StatefulWidget {
  const WordsPage({Key? key, this.year, this.month, this.day, this.hour})
      : super(key: key);
  final int? year;
  final int? month;
  final int? day;
  final int? hour;
  @override
  WordsPageState createState() => WordsPageState();
}

class WordsPageState extends State<WordsPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _input() {
    Solar solar = Solar.fromYmdHms(
        widget.year!, widget.month!, widget.day!, widget.hour!, 0, 0);
    Lunar lunar = solar.getLunar();
    return Container(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              direction: Axis.vertical,
              children: '基于精准量化的四柱八字'
                  .split("")
                  .map((string) => Text(
                        string,
                        style:
                            const TextStyle(fontSize: 30, color: Colors.grey),
                      ))
                  .toList(),
            ),
            const SizedBox(
              width: 3,
            ),
            Wrap(
              direction: Axis.vertical,
              children: '实现人生可观察可预测'
                  .split("")
                  .map((string) => Text(
                        string,
                        style:
                            const TextStyle(fontSize: 30, color: Colors.grey),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, color: Colors.grey),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '公历 ${solar.toYmdHms()} 星期${lunar.getWeekInChinese()}',
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                
              ],
            ),
          ],
        ),
      ),
      padding: const EdgeInsets.all(6.0),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, style: BorderStyle.solid),
          left: BorderSide(width: 1, style: BorderStyle.solid),
          right: BorderSide(width: 1, style: BorderStyle.solid),
          bottom: BorderSide(width: 1, style: BorderStyle.solid),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('四柱八字排盘'),
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _input(),
          ),
        ),
      ),
    );
  }
}
