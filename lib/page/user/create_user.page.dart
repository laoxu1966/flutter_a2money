import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';

import '../../service/user.service.dart';

import '../home/markdown.page.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({Key? key}) : super(key: key);
  @override
  CreateUserPageState createState() => CreateUserPageState();
}

class CreateUserPageState extends State<CreateUserPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();

  bool agree = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    displayNameController.dispose();

    super.dispose();
  }

  void _submitForm() async {
    final FormState form = formKey.currentState as FormState;
    if (!form.validate()) {
      showToast('表单校验未通过', context);
      return;
    }
    form.save();

    var response = await context.read<UserService>().createUser(
      usernameController.text.trim(),
      passwordController.text,
      {
        'displayName': displayNameController.text,
      },
    );

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();

      showToast('提交成功，系统已经自动分配一个随机的头像(登录后可以上传自定义的头像)。', context);
    } else if (response?.statusCode == 409) {
      showToast('提交失败，因为你输入的用户名已存在。', context);
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
          decoration: const InputDecoration(
            icon: Icon(AntDesign.user),
            labelText: '用户名',
            hintText: '电子邮件账号或手机号码',
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
            labelText: '重复一遍密码(8+)',
          ),
        ),
        TextFormField(
          controller: displayNameController,
          maxLength: 36,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.isEmpty) {
              return '显示名称(昵称)不能为空';
            } else if (val.length > 36) {
              return '长度不能大于36';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            displayNameController.text = val!;
          },
          decoration: InputDecoration(
            icon: const Icon(AntDesign.user),
            labelText: '显示名称(昵称)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                displayNameController.clear();
              },
            ),
          ),
        ),
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '注册帐号',
          ),
          onPressed: agree
              ? () {
                  _submitForm();
                }
              : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: agree,
              shape: const CircleBorder(),
              activeColor: Theme.of(context).colorScheme.secondary,
              onChanged: (bool? value) {
                setState(() {
                  agree = value!;
                });
              },
            ),
            const Text(
              '我已经阅读并同意',
            ),
            TextButton(
              child: Text.rich(
                TextSpan(
                  text: '服务条款',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarkdownPage(
                        title: '服务条款', file: 'assets/markdown/TERMS.md'),
                  ),
                );
              },
            ),
            const Text(
              '和',
            ),
            TextButton(
              child: Text.rich(
                TextSpan(
                  text: '隐私政策',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarkdownPage(
                        title: '隐私政策', file: 'assets/markdown/PRIVACY.md'),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册帐号'),
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
