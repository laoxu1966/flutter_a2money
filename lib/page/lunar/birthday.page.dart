import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';

import 'words.page.dart';

class BirthDayPage extends StatefulWidget {
  const BirthDayPage({Key? key}) : super(key: key);
  @override
  BirthDayPageState createState() => BirthDayPageState();
}

class BirthDayPageState extends State<BirthDayPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController hourController = TextEditingController();
  int sexSelected = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    yearController.dispose();
    monthController.dispose();
    dayController.dispose();
    hourController.dispose();

    super.dispose();
  }

  void _submitForm() async {
    final FormState form = formKey.currentState as FormState;
    if (!form.validate()) {
      showToast('表单校验未通过', context);
      return;
    }
    form.save();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordsPage(
          year: int.tryParse(yearController.text),
          month: int.tryParse(monthController.text),
          day: int.tryParse(dayController.text),
          hour: int.tryParse(hourController.text),
        ),
      ),
    );
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: yearController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.isEmpty ||
                int.tryParse(val) == null ||
                int.tryParse(val)! < 1 ||
                int.tryParse(val)! > DateTime.now().year) {
              return '出生年不正确';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            yearController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Fontisto.date),
            labelText: '出生年',
          ),
        ),
        TextFormField(
          controller: monthController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.isEmpty ||
                int.tryParse(val) == null ||
                int.tryParse(val)! < 1 ||
                int.tryParse(val)! > 12) {
              return '出生月不正确';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            monthController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Fontisto.date),
            labelText: '出生月',
          ),
        ),
        TextFormField(
          controller: dayController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.isEmpty ||
                int.tryParse(val) == null ||
                int.tryParse(val)! < 1 ||
                int.tryParse(val)! > 31) {
              return '出生日不正确';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            dayController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Fontisto.date),
            labelText: '出生日',
          ),
        ),
        TextFormField(
          controller: hourController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.isEmpty ||
                int.tryParse(val) == null ||
                int.tryParse(val)! < 0 ||
                int.tryParse(val)! > 23) {
              return '出生时不正确';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            hourController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Fontisto.date),
            labelText: '出生时',
          ),
        ),
        DropdownButtonFormField(
          value: sexSelected,
          decoration: const InputDecoration(
            labelText: '性别',
            icon: Icon(Icons.man),
          ),
          onChanged: (dynamic val) {
            setState(() {
              sexSelected = val;
            });
          },
          items: ['男', '女'].map((item) {
            return DropdownMenuItem(
              child: Text(item),
              value: ['男', '女'].indexOf(item),
            );
          }).toList(),
        ),
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '提交',
          ),
          onPressed: () {
            _submitForm();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('输入出生年月日时'),
      ),
      body: Form(
        key: formKey,
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
