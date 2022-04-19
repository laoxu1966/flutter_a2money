import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/user.model.dart';

import '../../service/user.service.dart';
import '../../service/respond.service.dart';

class UpdateSettlementPage extends StatefulWidget {
  final int? id;
  final Map<String, dynamic>? settlementAB;
  @override
  const UpdateSettlementPage({Key? key, this.id, this.settlementAB})
      : super(key: key);

  @override
  UpdateSettlementPageState createState() => UpdateSettlementPageState();
}

class UpdateSettlementPageState extends State<UpdateSettlementPage> {
  final formKey = GlobalKey<FormState>();

  User? user;
  String? helperText;

  final TextEditingController originalpayingController =
      TextEditingController();
  final TextEditingController payingController = TextEditingController();
  final TextEditingController originalpayableController =
      TextEditingController();
  final TextEditingController payableController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if ((widget.settlementAB ?? {}).isNotEmpty) {
      originalpayingController.text =
          widget.settlementAB!['originalpaying'].toString();
      payingController.text = widget.settlementAB!['paying'].toString();
      originalpayableController.text =
          widget.settlementAB!['originalpayable'].toString();
      payableController.text = widget.settlementAB!['payable'].toString();
      noteController.text = widget.settlementAB!['note'] ?? '';

      if (payingController.text == '0') {
        helperText = '这意味着，发起方的预授权将被解除，而响应方的预授权将转支付，从而使发起方获得收入。';
      } else if (payingController.text == '1') {
        helperText = '这意味着，响应方的预授权将被解除，而发起方的预授权将转支付，从而使响应方获得收入。';
      }
    }
  }

  @override
  void dispose() {
    originalpayingController.dispose();
    payingController.dispose();
    originalpayableController.dispose();
    payableController.dispose();
    noteController.dispose();

    super.dispose();
  }

  void _submitForm() async {
    final FormState form = formKey.currentState!;
    if (!form.validate()) {
      showToast('表单校验未通过', context);
      return;
    }
    form.save();

    Map<String, dynamic>? settlementAB = widget.settlementAB;
    settlementAB!['paying'] = int.tryParse(payingController.text) ?? 0;
    settlementAB['payable'] = num.tryParse(payableController.text) ?? 0.0;
    settlementAB['note'] = noteController.text.trim();

    if (json.encode(settlementAB).length > 510) {
      showToast(
          '提交失败，因为结算方案总字符数是${json.encode(settlementAB).length}，超过了510。',
          context);
      return;
    }

    var response = await Provider.of<RespondService>(context, listen: false)
        .updateSettlementAB(widget.id, settlementAB);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();
      showToast('提交成功，稍后请刷新。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Widget _originalpaying() {
    return DropdownButtonFormField(
      value: originalpayingController.text,
      decoration: const InputDecoration(
        icon: Icon(FontAwesome5Brands.amazon_pay),
        labelText: '支付方向(原)',
      ),
      disabledHint:
          Text(payingArr[int.tryParse(originalpayingController.text) ?? 0]),
      onChanged: null,
      items: payingArr.map((item) {
        return DropdownMenuItem(
          child: Text(item),
          value: payingArr.indexOf(item).toString(),
        );
      }).toList(),
    );
  }

  Widget _paying() {
    return DropdownButtonFormField(
      value: payingController.text,
      decoration: InputDecoration(
        icon: const Icon(FontAwesome5Brands.amazon_pay),
        labelText: '支付方向',
        helperText: '$helperText',
        helperStyle: const TextStyle(
          color: Colors.red,
        ),
        helperMaxLines: 3,
      ),
      onChanged: (dynamic val) {
        setState(() {
          payingController.text = val;
          if (val == '0') {
            helperText = '这意味着，发起方的预授权将被解除，而响应方的预授权将转支付，从而使发起方获得收入。';
          } else if (val == '1') {
            helperText = '这意味着，响应方的预授权将被解除，而发起方的预授权将转支付，从而使响应方获得收入。';
          }
        });
      },
      items: payingArr.map((String item) {
        return DropdownMenuItem<String>(
          child: Text(item),
          value: payingArr.indexOf(item).toString(),
        );
      }).toList(),
    );
  }

  Widget _originalpayable() {
    return TextFormField(
      enabled: false,
      controller: originalpayableController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onSaved: (val) {
        originalpayableController.text = val!;
      },
      decoration: const InputDecoration(
        icon: Icon(Icons.payment),
        labelText: '结算金额(原)',
      ),
    );
  }

  Widget _payable() {
    return TextFormField(
      controller: payableController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (val) {
        if (val!.isEmpty || (num.tryParse(val) ?? 0) <= 0.0) {
          return '结算金额的格式或数值不正确。';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        payableController.text = val!;
      },
      decoration: const InputDecoration(
        icon: Icon(Icons.payment),
        labelText: '结算金额',
      ),
    );
  }

  Widget _note() {
    return TextFormField(
      controller: noteController,
      maxLines: 3,
      maxLength: 128,
      textInputAction: TextInputAction.newline,
      validator: (val) {
        if (val!.isEmpty) {
          return '关于结算方案的说明不能为空';
        } else if (val.trim().length > 128) {
          return '关于结算方案的说明不能超过128个字';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        noteController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(MaterialIcons.note),
        labelText: '关于结算方案的说明',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            noteController.clear();
          },
        ),
      ),
    );
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        _originalpaying(),
        _paying(),
        _originalpayable(),
        _payable(),
        _note(),
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '提交结算方案',
          ),
          onPressed: () {
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => confirm(context,
                  '确定要提交结算方案吗？如果对方在15天内没有同意你的结算方案，系统管理员将自动介入调解，调解将形成最终结算方案，不再接受申诉。'),
            ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
              if (value == ConfirmDialogAction.OK) {
                _submitForm();
              }
              return;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserService>().user;
    if (user == null) {
      return anonymous(context, true);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('提交结算方案'),
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
