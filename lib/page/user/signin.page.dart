import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';

import '../../model/user.model.dart';

import '../../service/user.service.dart';
import '../../service/pref.service.dart';

import 'reset_password.page.dart';
import 'create_user.page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);
  @override
  SigninPageState createState() => SigninPageState();
}

class SigninPageState extends State<SigninPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> parsedJson = {};
    if (Pref.containsKey('signin')) {
      parsedJson = json.decode(Pref.getString('signin')!);
      usernameController.text = parsedJson['username'] ?? '';
      passwordController.text = parsedJson['password'] ?? '';
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    final FormState form = formKey.currentState as FormState;

    if (!form.validate()) {
      showToast('表单校验未通过', context);
      return;
    }

    form.save();

    await Pref.setString(
      'signin',
      json.encode(
        {
          'username': usernameController.text,
          'password': passwordController.text
        },
      ),
    );

    var response = await Provider.of<UserService>(context, listen: false)
        .signin(usernameController.text, passwordController.text);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();
      User? user = response?.user;
      if (user!.role! >= 0) {
        showToast('提交成功。', context);
      } else if (user.role! == -1) {
        showToast('提交成功，但账号被系统管理员暂时封禁，离解禁最多还有7天，目前只能进行有限操作。', context);
      }
    } else if (response?.statusCode == 401) {
      showToast('提交失败，因为账号或密码错误。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        TextFormField(
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
            hintText: '电子邮件帐号或手机号码',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                usernameController.clear();
              },
            ),
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
            labelText: '密码(8+)',
          ),
        ),
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '登录',
          ),
          onPressed: () {
            _submitForm();
          },
        ),
        TextButton(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '还没有账号？',
                  style: TextStyle(color: Colors.grey),
                ),
                TextSpan(
                  text: '注册账号',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateUserPage(),
              ),
            );
          },
        ),
        TextButton(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '忘记密码了？',
                  style: TextStyle(color: Colors.grey),
                ),
                TextSpan(
                  text: '重置密码',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ResetPasswordPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: _input(),
          ),
        ),
      ),
    );
  }
}
