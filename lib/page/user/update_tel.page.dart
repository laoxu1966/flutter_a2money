import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/ui.dart';

import '../../service/user.service.dart';

class UpdateTelPage extends StatefulWidget {
  final String? tel;
  @override
  const UpdateTelPage({Key? key, this.tel}) : super(key: key);
  @override
  UpdateTelPageState createState() => UpdateTelPageState();
}

class UpdateTelPageState extends State<UpdateTelPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final telKey = GlobalKey();

  final TextEditingController telController = TextEditingController();
  final TextEditingController hashController = TextEditingController();

  Timer? timer;
  int count = 0;

  void startTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) => {
        setState(() {
          if (count < 1) {
            timer!.cancel();
          } else {
            count = count - 1;
          }
        })
      },
    );
  }

  @override
  void initState() {
    super.initState();

    telController.text = widget.tel ?? '';
  }

  @override
  void dispose() {
    telController.dispose();
    hashController.dispose();

    if (timer != null) {
      timer!.cancel();
    }

    super.dispose();
  }

  Future _verifyUsername() async {
    final FormFieldState tel =
        telKey.currentState as FormFieldState<dynamic>;
    if (!tel.validate()) {
      showToast('请输入正确的手机号码。', context);
      return;
    }
    tel.save();

    var response = await context
        .read<UserService>()
        .verifyTel(telController.text);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      count = 120;

      startTimer();

      showToast('提交成功，请查收手机短信，并在120秒内输入验证码。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  void _submitForm() async {
    final FormState form = formKey.currentState as FormState;

    if (!form.validate()) {
      showToast('表单校验未通过', context);
      return;
    }

    form.save();

    var response = await context.read<UserService>().updateTel(
        telController.text.trim(), hashController.text.trim());

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();

      showToast('提交成功。', context);
    } else if (response?.statusCode == 412) {
      showToast('提交失败，因为输入的验证码不正确。', context);
    } else if (response?.statusCode == 413) {
      showToast('提交失败，因为1小时内最多验证1次。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        TextFormField(
          key: telKey,
          controller: telController,
          textInputAction: TextInputAction.next,
          validator: (val) {
            RegExp regexTel = RegExp('^1[0-9]{10}\$');
            if (!regexTel.hasMatch(val!)) {
              return '手机号码格式不正确。';
            }
            return null;
          },
          onSaved: (val) {
            telController.text = val!;
          },
          decoration: InputDecoration(
            icon: const Icon(Icons.phone),
            labelText: '手机号码',
            suffixIcon: count == 0
                ? TextButton(
                    child: const Text('获取验证码'),
                    onPressed: () => _verifyUsername(),
                  )
                : null,
          ),
        ),
        TextFormField(
          controller: hashController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.trim().length != 6) {
              return '请输入收到的6位验证码。';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            hashController.text = val!;
          },
          decoration: InputDecoration(
            icon: const Icon(Icons.verified_user),
            labelText: '验证码',
            suffixIcon: count > 0
                ? TextButton(
                    child: Text('$count 秒'),
                    onPressed: null,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '验证手机号码',
          ),
          onPressed: () {
            _submitForm();
          },
        ),
        const SizedBox(height: 15.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('验证手机号码'),
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
