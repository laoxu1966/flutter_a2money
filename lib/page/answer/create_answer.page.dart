import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/user.model.dart';
import '../../model/question.model.dart';

import '../../service/user.service.dart';
import '../../service/pref.service.dart';
import '../../service/answer.service.dart';
import '../../service/captcha.service.dart';

class CreateAnswerPage extends StatefulWidget {
  final Question? question;
  @override
  const CreateAnswerPage({Key? key, this.question}) : super(key: key);

  @override
  CreateAnswerPageState createState() => CreateAnswerPageState();
}

class CreateAnswerPageState extends State<CreateAnswerPage> {
  Uint8List bytes = Uint8List.fromList([]);

  final formKey = GlobalKey<FormState>();

  User? user;

  bool isComposing = false;

  final TextEditingController desController = TextEditingController();
  final TextEditingController captchaController = TextEditingController();

  Future _getData() async {
    var response = await context.read<CaptchaService>().getCaptcha();

    if (response != null && response?.statusCode == 200) {
      bytes = Uint8List.fromList(response.svg.codeUnits);

      if (mounted) {
        setState(() {
          //
        });
      }
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  @override
  void initState() {
    super.initState();

    Map<String, dynamic>? parsedJson = {};
    if (Pref.containsKey('answer')) {
      parsedJson = json.decode(Pref.getString('answer')!);
    }
    if (parsedJson!.isNotEmpty) {
      desController.text = parsedJson['des'] ?? '';
    }

    _getData();
  }

  @override
  void dispose() {
    desController.dispose();
    captchaController.dispose();

    super.dispose();
  }

  void _saveForm() async {
    final FormState form = formKey.currentState!;
    form.save();

    Map<String, dynamic> parsedJson = {
      "des": desController.text,
    };

    await Pref.setString(
      'answer',
      json.encode(parsedJson),
    );

    showToast('???????????????', context);
  }

  void _deleteForm() async {
    Pref.remove('answer');

    showToast('???????????????', context);
  }

  void _submitForm() async {
    final FormState form = formKey.currentState!;
    if (!form.validate()) {
      isComposing = false;
      showToast('?????????????????????', context);
      return;
    }
    form.save();

    var response =
        await Provider.of<AnswerService>(context, listen: false).createAnswer(
      widget.question!.id,
      widget.question!.uid,
      desController.text.trim(),
      captchaController.text,
    );

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();
      _deleteForm();
      showToast('?????????????????????????????????', context);
    } else if (response?.statusCode == 412) {
      _getData();
      isComposing = false;
      showToast('????????????????????????????????????????????????????????????', context);
    } else {
      _getData();
      isComposing = false;
      showToast(response?.statusMessage, context);
    }
  }

  Widget _des() {
    return TextFormField(
      controller: desController,
      maxLines: 9,
      minLines: 3,
      maxLength: 1020,
      textInputAction: TextInputAction.newline,
      validator: (val) {
        if (val!.trim().length > 1020) {
          return '??????????????????1020??????';
        } else if (val.isEmpty) {
          return '??????????????????';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        desController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(MaterialIcons.question_answer),
        labelText: '??????',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            desController.clear();
          },
        ),
      ),
    );
  }

  Widget _captcha() {
    return TextFormField(
      controller: captchaController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (val) {
        if (val!.trim().length != 4) {
          return '?????????????????????4?????????????????????';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        captchaController.text = val!;
      },
      decoration: const InputDecoration(
        icon: Icon(Icons.verified_user),
        labelText: '???????????????',
      ),
    );
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        _des(),
        Container(
          padding: const EdgeInsets.only(left: 33.0),
          child: Row(
            children: [
              if (bytes.isNotEmpty)
                SvgPicture.memory(
                  bytes,
                  color: Colors.grey,
                  placeholderBuilder: (BuildContext context) =>
                      const CircularProgressIndicator(),
                ),
              Expanded(
                child: Container(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 21),
                onPressed: () {
                  setState(() {
                    _getData();
                  });
                },
              ),
            ],
          ),
        ),
        _captcha(),
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '??????',
          ),
          onPressed: () {
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  confirm(context, '?????????????????????????????????'),
            ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
              if (value == ConfirmDialogAction.OK) {
                if (!isComposing) {
                  isComposing = true;
                  _submitForm();
                }
              }
              return;
            });
          },
        ),
        const SizedBox(height: 6.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserService>().user;
    if (user == null) {
      return anonymous(context, true);
    } else if (user!.role! == -1) {
      return blocked(context);
    } else if ((user!.email ?? '').isEmpty) {
      return verificationEmail(context);
    }

    return WillPopScope(
      onWillPop: () async {
        showDialog<ConfirmDialogAction>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              confirm(context, '???????????????????????????????????????????????????'),
        ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
          if (value == ConfirmDialogAction.OK) {
            Navigator.of(context).pop(true);
          }
          return;
        });
        return Future(() => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('????????????'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Feather.save),
              onPressed: () {
                _saveForm();
              },
            ),
            IconButton(
              icon: const Icon(Feather.delete),
              onPressed: () {
                _deleteForm();
              },
            ),
          ],
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
      ),
    );
  }
}
