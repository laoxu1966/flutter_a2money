import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/user.model.dart';

import '../../service/user.service.dart';
import '../../service/respond.service.dart';

class UpdateContractPage extends StatefulWidget {
  final int? id;
  final Map<String, dynamic>? contractAB;
  @override
  const UpdateContractPage({Key? key, this.id, this.contractAB})
      : super(key: key);

  @override
  UpdateContractPageState createState() => UpdateContractPageState();
}

class UpdateContractPageState extends State<UpdateContractPage> {
  final formKey = GlobalKey<FormState>();

  User? user;

  final TextEditingController payingController = TextEditingController();
  final TextEditingController payableController = TextEditingController();
  final TextEditingController understandController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController deliverController = TextEditingController();
  final TextEditingController deliverDateController = TextEditingController();
  final TextEditingController deliverTimeController = TextEditingController();
  final TextEditingController violateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.contractAB!.isNotEmpty) {
      payingController.text = widget.contractAB!['paying'].toString();
      payableController.text = widget.contractAB!['payable'].toString();
      understandController.text = widget.contractAB!['understand'] ?? '';
      subjectController.text = widget.contractAB!['subject'] ?? '';
      deliverController.text = widget.contractAB!['deliver'] ?? '';
      deliverDateController.text = widget.contractAB!['deliverDate'] ?? '';
      deliverTimeController.text = widget.contractAB!['deliverTime'] ?? '';
      violateController.text = widget.contractAB!['violate'] ?? '';
    }
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

    super.dispose();
  }

  void _submitForm() async {
    final FormState form = formKey.currentState!;
    if (!form.validate()) {
      showToast('?????????????????????', context);
      return;
    }
    form.save();

    Map<String, dynamic> contractAB = widget.contractAB!;
    contractAB['paying'] = int.tryParse(payingController.text) ?? 0;
    contractAB['payable'] = num.tryParse(payableController.text) ?? 0.0;
    contractAB['understand'] = understandController.text.trim();
    contractAB['subject'] = subjectController.text.trim();
    contractAB['deliver'] = deliverController.text.trim();
    contractAB['deliverDate'] = deliverDateController.text;
    contractAB['deliverTime'] = deliverTimeController.text;
    contractAB['violate'] = violateController.text.trim();

    if (json.encode(contractAB).length > 1020) {
      showToast(
          '??????????????????????????????????????????${json.encode(contractAB).length}????????????1020???', context);
      return;
    }

    var response = await Provider.of<RespondService>(context, listen: false)
        .updateContractAB(widget.id, contractAB);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();
      showToast('?????????????????????????????????', context);
    } else {
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
          return '??????????????????????????????128??????';
        } else if (val.isEmpty) {
          return '??????????????????????????????';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        understandController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(MaterialCommunityIcons.book_open_outline),
        labelText: '??????????????????',
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
        labelText: '????????????',
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
          return '??????????????????????????????????????????';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        payableController.text = val!;
      },
      decoration: const InputDecoration(
        icon: Icon(Icons.payment),
        labelText: '????????????',
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
          return '???????????????????????????????????????255??????';
        } else if (val.isEmpty) {
          return '???????????????????????????????????????';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        subjectController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(Octicons.package),
        labelText: '???????????????????????????',
        helperText: '???????????????????????????????????????????????????(?????????????????????????????????)????????????1?????????',
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
          return '????????????????????????128??????';
        } else if (val.isEmpty) {
          return '????????????????????????';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        deliverController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(MaterialCommunityIcons.truck_outline),
        labelText: '????????????',
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
              return '??????????????????????????????10??????';
            } else if (val.isEmpty) {
              return '??????????????????????????????';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            deliverDateController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.date_range),
            labelText: '??????????????????',
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
              return '??????????????????????????????8??????';
            } else if (val.isEmpty) {
              return '??????????????????????????????';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            deliverTimeController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.timer),
            labelText: '??????????????????',
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
          return '????????????????????????255??????';
        } else if (val.isEmpty) {
          return '????????????????????????';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        violateController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(Octicons.law),
        labelText: '????????????',
        helperText:
            '???????????????????????????????????????????????????????????????????????????????????????????????????3??????????????????(????????????)???????????????????????????????????????(????????????)???????????????????????????',
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
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '??????',
          ),
          onPressed: () {
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  confirm(context, '?????????????????????????????????'),
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
        title: const Text('????????????'),
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
