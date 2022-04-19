import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/ui.dart';

import '../../service/user.service.dart';

class UpdateEmailPage extends StatefulWidget {
  final String? email;
  @override
  const UpdateEmailPage({Key? key, this.email}) : super(key: key);
  @override
  UpdateEmailPageState createState() => UpdateEmailPageState();
}

class UpdateEmailPageState extends State<UpdateEmailPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailKey = GlobalKey();

  final TextEditingController emailController = TextEditingController();
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

    emailController.text = widget.email ?? '';
  }

  @override
  void dispose() {
    emailController.dispose();
    hashController.dispose();

    if (timer != null) {
      timer!.cancel();
    }

    super.dispose();
  }

  Future _verifyEmail() async {
    final FormFieldState email =
        emailKey.currentState as FormFieldState<dynamic>;
    if (!email.validate()) {
      showToast('请输入正确的电子邮件账号。', context);
      return;
    }
    email.save();

    var response = await context
        .read<UserService>()
        .verifyEmail(emailController.text);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      count = 120;

      startTimer();

      showToast('提交成功，请查收电子邮件，并在120秒内输入验证码。', context);
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

    var response = await context.read<UserService>().updateEmail(
        emailController.text.trim(), hashController.text.trim());

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();

      showToast('提交成功。', context);
    } else if (response?.statusCode == 412) {
      showToast('提交失败，因为输入的验证码不正确。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        TextFormField(
          key: emailKey,
          controller: emailController,
          textInputAction: TextInputAction.next,
          validator: (val) {
            RegExp regexMail = RegExp(r'^\S+@\S+\.\S+$');
            if (!regexMail.hasMatch(val!)) {
              return '电子邮件账号格式不正确。';
            }
            return null;
          },
          onSaved: (val) {
            emailController.text = val!;
          },
          decoration: InputDecoration(
            icon: const Icon(Icons.email),
            labelText: '电子邮件账号',
            suffixIcon: count == 0
                ? TextButton(
                    child: const Text('获取验证码'),
                    onPressed: () => _verifyEmail(),
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
            '验证电子邮件账号',
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
        title: const Text('验证电子邮件账号'),
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
