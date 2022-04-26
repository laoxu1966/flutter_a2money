import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/user.model.dart';
import '../../model/answer.model.dart';

import '../../service/user.service.dart';
import '../../service/answer.service.dart';

class UpdateAnswerPage extends StatefulWidget {
  final int? id;
  final Answer? answer;
  @override
  const UpdateAnswerPage({Key? key, this.id, this.answer})
      : super(key: key);

  @override
  UpdateAnswerPageState createState() => UpdateAnswerPageState();
}

class UpdateAnswerPageState extends State<UpdateAnswerPage> {
  final formKey = GlobalKey<FormState>();

  User? user;

  final TextEditingController desController = TextEditingController();

  @override
  void initState() {
    super.initState();

    desController.text = widget.answer!.des;
  }

  @override
  void dispose() {
    desController.dispose();

    super.dispose();
  }

  void _submitForm() async {
    final FormState form = formKey.currentState!;
    if (!form.validate()) {
      showToast('表单校验未通过', context);
      return;
    }
    form.save();

    var response =
        await Provider.of<AnswerService>(context, listen: false).updateAnswer(
      widget.id!,
      desController.text.trim(),
    );

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();
      showToast('提交成功，稍后请刷新。', context);
    } else {
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
          return '答案不能超过1020个字';
        } else if (val.isEmpty) {
          return '答案不能为空';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        desController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(MaterialIcons.question_answer),
        labelText: '答案',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            desController.clear();
          },
        ),
      ),
    );
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        _des(),
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '提交',
          ),
          onPressed: () {
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  confirm(context, '确定要提交这个答案吗？'),
            ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
              if (value == ConfirmDialogAction.OK) {
                _submitForm();
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
              confirm(context, '确定要退出吗？请先确定是否已经存档'),
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
          title: const Text('修改答案'),
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
