import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';

import '../../service/user.service.dart';

class UpdateUsernamePage extends StatefulWidget {
  final String? username;
  @override
  const UpdateUsernamePage({Key? key, this.username}) : super(key: key);
  @override
  UpdateUsernamePageState createState() => UpdateUsernamePageState();
}

class UpdateUsernamePageState extends State<UpdateUsernamePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final usernameKey = GlobalKey();

  final TextEditingController usernameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();

    usernameController.text = widget.username ?? '';
  }

  @override
  void dispose() {
    usernameController.dispose();

    super.dispose();
  }

  void _submitForm() async {
    final FormState form = formKey.currentState as FormState;

    if (!form.validate()) {
      showToast('表单校验未通过', context);
      return;
    }

    form.save();

    var response = await context.read<UserService>().updateUsername(
        usernameController.text.trim());

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();

      showToast('提交成功。', context);
    } else if (response?.statusCode == 409) {
      showToast('提交失败，因为输入的用户名已存在。', context);
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
          decoration: const InputDecoration(
            icon: Icon(AntDesign.user),
            labelText: '用户名',
            hintText: '电子邮件账号或手机号码',
          ),
        ),
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '修改用户名',
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
        title: const Text('修改用户名'),
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
