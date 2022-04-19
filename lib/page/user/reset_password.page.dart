import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';

import '../../service/user.service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);
  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final usernameKey = GlobalKey();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController hashController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
  }

  @override
  void dispose() {
    usernameController.dispose();
    hashController.dispose();
    passwordController.dispose();

    if (timer != null) {
      timer!.cancel();
    }

    super.dispose();
  }

  void _verifyUsername() async {
    final FormFieldState username =
        usernameKey.currentState as FormFieldState<dynamic>;
    if (!username.validate()) {
      showToast('请输入正确的用户名。', context);
      return;
    }
    username.save();

    var response = await context
        .read<UserService>()
        .verifyEmail(usernameController.text);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      count = 120;

      startTimer();

      showToast('提交成功，请查收电子邮件或手机短信，并在120秒内输入验证码。', context);
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

    var response = await context.read<UserService>().resetPassword(
        usernameController.text, hashController.text, passwordController.text);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();

      showToast('提交成功，请重新登录。', context);
    } else if (response?.statusCode == 404) {
      showToast('提交失败，因为没有找到你输入的用户名。', context);
    } else if (response?.statusCode == 412) {
      showToast('提交失败，因为你输入的验证码不正确。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        TextFormField(
          key: usernameKey,
          controller: usernameController,
          textInputAction: TextInputAction.next,
          validator: (val) {
            RegExp regexMail = RegExp(r'^\S+@\S+\.\S+$');
            RegExp regexTel = RegExp('^1[0-9]{10}\$');
            if (!regexMail.hasMatch(val!) && !regexTel.hasMatch(val)) {
              return '用户名格式不正确。';
            }
            return null;
          },
          onSaved: (val) {
            usernameController.text = val!;
          },
          decoration: InputDecoration(
            icon: const Icon(AntDesign.user),
            labelText: '用户名',
            hintText: '电子邮件账号或手机号码',
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
        TextFormField(
          controller: passwordController,
          obscureText: true,
          textInputAction: TextInputAction.next,
          validator: (val) {
            RegExp regex =
                RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[\W_]).{8,}$');
            if (regex.hasMatch(val!)) {
              return null;
            }
            return '8+，至少一个大小写字母、数字、特殊字符。';
          },
          onSaved: (val) {
            passwordController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.keyboard),
            labelText: '拟采用的新密码(8+)',
          ),
        ),
        TextFormField(
          obscureText: true,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val == passwordController.text) {
              return null;
            }
            return '密码不匹配。';
          },
          onSaved: (val) {
            passwordController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.keyboard),
            labelText: '重复一遍新密码(8+)',
          ),
        ),
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '重置密码',
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
        title: const Text('重置密码'),
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
