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
import '../../model/ability.model.dart';

import '../../service/user.service.dart';
import '../../service/pref.service.dart';
import '../../service/respond.service.dart';
import '../../service/captcha.service.dart';

class CreateRespondPage extends StatefulWidget {
  final Ability? ability;
  @override
  const CreateRespondPage({Key? key, this.ability}) : super(key: key);

  @override
  CreateRespondPageState createState() => CreateRespondPageState();
}

class CreateRespondPageState extends State<CreateRespondPage> {
  Uint8List bytes = Uint8List.fromList([]);

  final formKey = GlobalKey<FormState>();

  User? user;

  bool isComposing = false;

  final TextEditingController payingController = TextEditingController();
  final TextEditingController payableController = TextEditingController();
  final TextEditingController understandController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController deliverController = TextEditingController();
  final TextEditingController deliverDateController = TextEditingController();
  final TextEditingController deliverTimeController = TextEditingController();
  final TextEditingController violateController = TextEditingController();
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

    payingController.text = widget.ability!.paying.toString();

    Map<String, dynamic>? parsedJson = {};
    if (Pref.containsKey('respond')) {
      parsedJson = json.decode(Pref.getString('respond')!);
    }

    if (parsedJson!.isNotEmpty) {
      payableController.text = parsedJson['payable'] ?? '';
      understandController.text = parsedJson['understand'] ?? '';
      subjectController.text = parsedJson['subject'] ?? '';
      deliverController.text = parsedJson['deliver'] ?? '';
      deliverDateController.text = parsedJson['deliverDate'] ?? '';
      deliverTimeController.text = parsedJson['deliverTime'] ?? '';
      violateController.text = parsedJson['violate'] ?? '';
    }

    _getData();
  }

  @override
  void dispose() {
    payingController.dispose();
    payableController.dispose();
    understandController.dispose();
    subjectController.dispose();
    deliverController.dispose();
    deliverDateController.dispose();
    deliverTimeController.dispose();
    violateController.dispose();
    captchaController.dispose();

    super.dispose();
  }

  void _saveForm() async {
    final FormState form = formKey.currentState!;
    form.save();

    Map<String, dynamic> parsedJson = {
      "payable": payableController.text,
      "understand": understandController.text,
      "subject": subjectController.text,
      "deliver": deliverController.text,
      "deliverDate": deliverDateController.text,
      "deliverTime": deliverTimeController.text,
      "violate": violateController.text,
    };

    await Pref.setString(
      'respond',
      json.encode(parsedJson),
    );

    showToast('提交成功。', context);
  }

  void _deleteForm() async {
    Pref.remove('respond');

    showToast('提交成功。', context);
  }

  void _submitForm() async {
    final FormState form = formKey.currentState!;
    if (!form.validate()) {
      isComposing = false;
      showToast('表单校验未通过', context);
      return;
    }
    form.save();

    Map<String, dynamic> contract = {
      "paying": int.tryParse(payingController.text) ?? 0,
      "payable": num.tryParse(payableController.text) ?? 0.0,
      "understand": understandController.text.trim(),
      "subject": subjectController.text.trim(),
      "deliver": deliverController.text.trim(),
      "deliverDate": deliverDateController.text,
      "deliverTime": deliverTimeController.text,
      "violate": violateController.text.trim(),
    };

    if (json.encode(contract).length > 1020) {
      showToast(
          '提交失败，因为合约总字符数是${json.encode(contract).length}，超过了1020。', context);
      return;
    }

    var response =
        await Provider.of<RespondService>(context, listen: false).createRespond(
      widget.ability!.id,
      widget.ability!.uid,
      contract,
      captchaController.text,
    );

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();
      _deleteForm();
      showToast('提交成功，稍后请刷新。', context);
    } else if (response?.statusCode == 412) {
      _getData();
      isComposing = false;
      showToast('提交失败，因为你输入的图形验证码不正确。', context);
    } else {
      _getData();
      isComposing = false;
      showToast(response?.statusMessage, context);
    }
  }

  Widget _understand() {
    return TextFormField(
      controller: understandController,
      maxLines: 6,
      minLines: 3,
      maxLength: 128,
      textInputAction: TextInputAction.newline,
      validator: (val) {
        if (val!.trim().length > 128) {
          return '对交易的理解不能超过128个字';
        } else if (val.isEmpty) {
          return '对交易的理解不能为空';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        understandController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(MaterialCommunityIcons.book_open_outline),
        labelText: '对交易的理解',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            understandController.clear();
          },
        ),
      ),
    );
  }

  Widget _paying() {
    return DropdownButtonFormField(
      value: payingController.text,
      decoration: const InputDecoration(
        icon: Icon(FontAwesome5Brands.amazon_pay),
        labelText: '支付方向',
      ),
      disabledHint: Text(payingArr[int.tryParse(payingController.text) ?? 0]),
      onChanged: null,
      items: payingArr.map((item) {
        return DropdownMenuItem(
          child: Text(item),
          value: payingArr.indexOf(item).toString(),
        );
      }).toList(),
    );
  }

  Widget _payable() {
    return TextFormField(
      controller: payableController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (val) {
        if (val!.isEmpty || (num.tryParse(val) ?? 0.0) <= 0) {
          return '合约金额的格式或数值不正确。';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        payableController.text = val!;
      },
      decoration: const InputDecoration(
        icon: Icon(Icons.payment),
        labelText: '合约金额',
      ),
    );
  }

  Widget _subject() {
    return TextFormField(
      controller: subjectController,
      maxLines: 6,
      minLines: 3,
      maxLength: 255,
      textInputAction: TextInputAction.newline,
      validator: (val) {
        if (val!.trim().length > 255) {
          return '交付物及其规格条件不能超过255个字';
        } else if (val.isEmpty) {
          return '交付物及其规格条件不能为空';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        subjectController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(Octicons.package),
        labelText: '交付物及其规格条件',
        helperText: '如果有多个条件，每个条件应单独编号(以便于违约责任字段引用)，编号从1开始。',
        helperMaxLines: 3,
        helperStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            subjectController.clear();
          },
        ),
      ),
    );
  }

  Widget _deliver() {
    return TextFormField(
      controller: deliverController,
      maxLines: 6,
      minLines: 3,
      maxLength: 128,
      textInputAction: TextInputAction.newline,
      validator: (val) {
        if (val!.trim().length > 128) {
          return '交付方式不能超过128个字';
        } else if (val.isEmpty) {
          return '交付方式不能为空';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        deliverController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(MaterialCommunityIcons.truck_outline),
        labelText: '交付方式',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            deliverController.clear();
          },
        ),
      ),
    );
  }

  Widget _deliverDate() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2021),
          lastDate: DateTime(2121),
        );

        if (picked != null) {
          deliverDateController.text = picked.toString().substring(0, 10);
          setState(() {
            //
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: deliverDateController,
          maxLength: 10,
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.trim().length > 10) {
              return '交付截止日期不能超过10个字';
            } else if (val.isEmpty) {
              return '交付截止日期不能为空';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            deliverDateController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.date_range),
            labelText: '交付截止日期',
          ),
        ),
      ),
    );
  }

  Widget _deliverTime() {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (picked != null) {
          String hh = picked.hour.toString();
          if (hh.length == 1) hh = '0' + hh;
          String mm = picked.minute.toString();
          if (mm.length == 1) mm = '0' + mm;
          deliverTimeController.text = hh + ':' + mm;
          setState(() {
            //
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: deliverTimeController,
          maxLength: 8,
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.length > 8) {
              return '交付截止时间不能超过8个字';
            } else if (val.isEmpty) {
              return '交付截止时间不能为空';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            deliverTimeController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.timer),
            labelText: '交付截止时间',
          ),
        ),
      ),
    );
  }

  Widget _violate() {
    return TextFormField(
      controller: violateController,
      maxLines: 6,
      minLines: 3,
      maxLength: 255,
      textInputAction: TextInputAction.newline,
      validator: (val) {
        if (val!.trim().length > 255) {
          return '违约责任不能超过255个字';
        } else if (val.isEmpty) {
          return '违约责任不能为空';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        violateController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(Octicons.law),
        labelText: '违约责任',
        helperText:
            '应针对上述具体的条款来写，例如：“如果违反‘交付物及其规格条件’第3条，则响应方(或发起方)有权中止交易，并罚没发起方(或响应方)的全部预授权；”。',
        helperMaxLines: 3,
        helperStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            violateController.clear();
          },
        ),
      ),
    );
  }

  Widget _svg() {
    return Padding(
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
          return '请输入上图中的4位图形验证码。';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        captchaController.text = val!;
      },
      decoration: const InputDecoration(
        icon: Icon(Icons.verified_user),
        labelText: '图形验证码',
      ),
    );
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        _understand(),
        _paying(),
        _payable(),
        _subject(),
        _deliver(),
        _deliverDate(),
        _deliverTime(),
        _violate(),
        _svg(),
        _captcha(),
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
                  confirm(context, '确定要提交这个响应吗？'),
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
          title: const Text('创建响应'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(AntDesign.save),
              onPressed: () {
                _saveForm();
              },
            ),
            IconButton(
              icon: const Icon(AntDesign.delete),
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
