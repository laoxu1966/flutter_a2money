import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/ui.dart';

import '../../service/user.service.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({Key? key}) : super(key: key);
  @override
  UpdatePasswordPageState createState() => UpdatePasswordPageState();
}

class UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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

    var response =
        await context.read<UserService>().updatePassword(passwordController.text);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();

      showToast('提交成功。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Widget _input() {
    return Column(
      children: <Widget>[
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
        const SizedBox(height: 6.0),
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
            '修改密码',
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
        title: const Text('修改密码'),
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
