import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';
import '../../common/carousel.dart';

import '../../model/user.model.dart';

import '../../service/user.service.dart';
import '../../service/pref.service.dart';
import '../../service/ability.service.dart';
import '../../service/captcha.service.dart';

class CreateAbilityPage extends StatefulWidget {
  final int? paying;
  @override
  const CreateAbilityPage({Key? key, this.paying}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CreateAbilityPageState();
  }
}

class CreateAbilityPageState extends State<CreateAbilityPage> {
  List<String>? files = [];
  Uint8List bytes = Uint8List.fromList([]);

  User? user;

  bool isComposing = false;
  bool emailCheck = false;
  bool telCheck = false;
  bool geoCheck = false;

  final formKey = GlobalKey<FormState>();

  final TextEditingController classificationController =
      TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  final TextEditingController riskController = TextEditingController();
  final TextEditingController respondDateController = TextEditingController();
  final TextEditingController respondTimeController = TextEditingController();
  final TextEditingController picController = TextEditingController();
  final TextEditingController captchaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController geoController = TextEditingController();

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

  Future _geoLocator() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Geolocator.openLocationSettings();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return Future.error('你的手机禁止了访问位置的权限，导致本平台无法获取位置信息。');
      }
    }

    Position? position = await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: true);
    position ??= await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 15));

    return '${position.latitude},${position.longitude}';
  }

  @override
  void initState() {
    super.initState();

    classificationController.text = '0';

    Map<String, dynamic>? parsedJson = {};
    if (Pref.containsKey('ability')) {
      parsedJson = json.decode(Pref.getString('ability')!);
    }

    if (parsedJson!.isNotEmpty) {
      classificationController.text = parsedJson['classification'];
      tagController.text = parsedJson['tag'] ?? '';
      titleController.text = parsedJson['title'] ?? '';
      desController.text = parsedJson['des'] ?? '';
      riskController.text = parsedJson['risk'] ?? '';
      respondDateController.text = parsedJson['respondDate'] ?? '';
      respondTimeController.text = parsedJson['respondTime'] ?? '';
      picController.text = parsedJson['pic'] ?? '';
      if (picController.text.isNotEmpty) {
        files = picController.text.split(',');
      }
    }

    _getData();
  }

  @override
  void dispose() {
    classificationController.dispose();
    tagController.dispose();
    titleController.dispose();
    desController.dispose();
    riskController.dispose();
    respondDateController.dispose();
    respondTimeController.dispose();
    picController.dispose();
    captchaController.dispose();
    emailController.dispose();
    telController.dispose();
    geoController.dispose();

    super.dispose();
  }

  void _saveForm() async {
    final FormState form = formKey.currentState!;
    form.save();

    Map<String, dynamic> parsedJson = {
      'classification': classificationController.text,
      'tag': tagController.text,
      'title': titleController.text,
      'des': desController.text,
      'risk': riskController.text,
      'respondDate': respondDateController.text,
      'respondTime': respondTimeController.text,
      'pic': picController.text,
    };

    await Pref.setString(
      'ability',
      json.encode(parsedJson),
    );

    showToast('提交成功。', context);
  }

  void _deleteForm() async {
    Pref.remove('ability');

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

    var response =
        await Provider.of<AbilityService>(context, listen: false).createAbility(
      widget.paying!,
      classificationController.text,
      tagController.text.trim(),
      titleController.text.trim(),
      desController.text.trim(),
      riskController.text.trim(),
      respondDateController.text,
      respondTimeController.text,
      files!,
      emailController.text,
      telController.text,
      geoController.text,
      captchaController.text,
      user!.id,
    );

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();
      _deleteForm();
      showToast('提交成功，但目前处于待审查状态，只能在“我发起的能力变现交易”中查到。', context);
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

  Widget _title() {
    return TextFormField(
      controller: titleController,
      maxLength: 128,
      textInputAction: TextInputAction.next,
      validator: (val) {
        if (val!.trim().length > 128) {
          return '标题不能超过128个字';
        } else if (val.isEmpty) {
          return '标题不能为空';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        titleController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(Icons.subject),
        labelText: '标题',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            titleController.clear();
          },
        ),
      ),
    );
  }

  Widget _des() {
    return TextFormField(
      controller: desController,
      maxLines: 6,
      minLines: 3,
      maxLength: 510,
      textInputAction: TextInputAction.newline,
      validator: (val) {
        if (val!.trim().length > 510) {
          return '关于供给或需求的详细描述不能超过510个字';
        } else if (val.isEmpty) {
          return '关于供给或需求的详细描述不能为空';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        desController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(Icons.description),
        labelText: '关于供给或需求的详细描述',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            desController.clear();
          },
        ),
      ),
    );
  }

  Widget _risk() {
    return TextFormField(
      controller: riskController,
      maxLines: 6,
      minLines: 3,
      maxLength: 255,
      textInputAction: TextInputAction.newline,
      validator: (val) {
        if (val!.trim().length > 255) {
          return '关于交易风险的提示不能超过255个字';
        } else if (val.isEmpty) {
          return '关于交易风险的提示不能为空';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        riskController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(Icons.warning),
        labelText: '关于交易风险的提示',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            riskController.clear();
          },
        ),
      ),
    );
  }

  Widget _classification() {
    return DropdownButtonFormField(
      value: classificationController.text,
      decoration: const InputDecoration(
        icon: Icon(Feather.list),
        labelText: '能力类型',
      ),
      onChanged: (dynamic val) {
        setState(() {
          classificationController.text = val;
          if (val == '2') {
            showToast('本平台禁止代写学位论文或买卖学位论文等行为，一经发现，交易将被隐藏。', context);
          }
        });
      },
      items: classificationArr.map((item) {
        return DropdownMenuItem(
          child: Text(item),
          value: classificationArr.indexOf(item).toString(),
        );
      }).toList(),
    );
  }

  Widget _tag() {
    return TextFormField(
      controller: tagController,
      maxLength: 16,
      textInputAction: TextInputAction.next,
      validator: (val) {
        if (val!.trim().length > 16) {
          return '标签不能超过16个字';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        tagController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(
          Feather.hash,
        ),
        labelText: '标签',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            tagController.clear();
          },
        ),
      ),
    );
  }

  Widget _respondDate() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2021),
          lastDate: DateTime(2121),
        );

        if (picked != null) {
          setState(() {
            respondDateController.text = picked.toString().substring(0, 10);
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: respondDateController,
          maxLength: 10,
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.trim().length > 10) {
              return '响应截止日期不能超过10个字';
            } else if (val.isEmpty) {
              return '响应截止日期不能为空';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            respondDateController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.date_range),
            labelText: '响应截止日期',
          ),
        ),
      ),
    );
  }

  Widget _respondTime() {
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
          respondTimeController.text = hh + ':' + mm;
          setState(() {
            //
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: respondTimeController,
          maxLength: 8,
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.length > 8) {
              return '响应截止时间不能超过8个字';
            } else if (val.isEmpty) {
              return '响应截止时间不能为空';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            respondTimeController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.timer),
            labelText: '响应截止时间',
          ),
        ),
      ),
    );
  }

  _pickButton() {
    return PopupMenuButton(
      icon: const Icon(
        Icons.photo_camera,
        color: Colors.grey,
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<ImageAction>>[
          PopupMenuItem(
            enabled: user != null,
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.photo_album,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '从相册选择图片',
                )
              ],
            ),
            value: ImageAction.GALLERY_IMAGE,
          ),
          PopupMenuItem(
            enabled: user != null,
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.photo_camera,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '用相机拍摄照片',
                )
              ],
            ),
            value: ImageAction.CAMERA_IMAGE,
          ),
        ];
      },
      onSelected: (ImageAction selected) async {
        switch (selected) {
          case ImageAction.GALLERY_IMAGE:
            final ImagePicker _picker = ImagePicker();
            final XFile? file = await _picker.pickImage(
              source: ImageSource.gallery,
              maxHeight: 1800,
              maxWidth: 600,
            );
            if (file != null) {
              files!.add(file.path);
              picController.text = files!.join(',');
              setState(() {
                //
              });
            }

            break;
          case ImageAction.CAMERA_IMAGE:
            final ImagePicker _picker = ImagePicker();
            final XFile? file = await _picker.pickImage(
              source: ImageSource.camera,
              maxHeight: 1800,
              maxWidth: 600,
            );
            if (file != null) {
              files!.add(file.path);
              picController.text = files!.join(',');
              setState(() {
                //
              });
            }
            break;
          default:
            showToast('$selected', context);
            break;
        }
      },
    );
  }

  Widget _pic() {
    return TextFormField(
      controller: picController,
      readOnly: true,
      textInputAction: TextInputAction.next,
      validator: (val) {
        return null;
      },
      onSaved: (val) {
        picController.text = val!;
      },
      decoration: InputDecoration(
        icon: const Icon(Icons.image),
        labelText: '附加图片',
        suffixIcon: files!.length < 3 ? _pickButton() : null,
      ),
    );
  }

  Widget _pics() {
    List<Widget> picWidgets = files!.map((url) {
      int index = files!.indexOf(url);

      return SizedBox(
        width: 120,
        height: 120,
        child: GestureDetector(
          child: getPicture(
            files![index].replaceAll('"', ''),
          ),
          onLongPress: () {
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  confirm(context, '确定要删除这个图片吗？'),
            ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
              if (value == ConfirmDialogAction.OK) {
                setState(() {
                  files!.removeAt(index);
                  picController.text = files!.join(',');
                });
              }
              return;
            });
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarouselPage(files!, index),
              ),
            );
          },
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.only(top: 6.0),
      child: Wrap(
        runSpacing: 6,
        spacing: 6,
        children: picWidgets,
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

  Widget _email() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: ListTile(
        leading: Checkbox(
          shape: const CircleBorder(),
          visualDensity: VisualDensity.compact,
          value: emailCheck,
          onChanged: (bool? value) {
            setState(() {
              emailCheck = value!;
              if (emailCheck) {
                emailController.text = user!.email!;
              } else {
                emailController.text = '';
              }
            });
          },
        ),
        title: Container(
          child: const Text('公开我的电子邮件账号'),
          padding: const EdgeInsets.only(top: 15),
        ),
        subtitle: Text(emailController.text),
      ),
    );
  }

  Widget _tel() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: ListTile(
        leading: Checkbox(
          shape: const CircleBorder(),
          visualDensity: VisualDensity.compact,
          value: telCheck,
          onChanged: (bool? value) {
            setState(() {
              telCheck = value!;
              if (telCheck) {
                telController.text = user!.tel!;
              } else {
                telController.text = '';
              }
            });
          },
        ),
        title: Container(
          child: const Text('公开我的手机号码'),
          padding: const EdgeInsets.only(top: 15),
        ),
        subtitle: Text(telController.text),
      ),
    );
  }

  Widget _geo() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: ListTile(
        leading: Checkbox(
          shape: const CircleBorder(),
          visualDensity: VisualDensity.compact,
          value: geoCheck,
          onChanged: (bool? value) async {
            String geoLocator = await _geoLocator();
            setState(() {
              geoCheck = value!;
              if (geoCheck) {
                geoController.text = geoLocator;
              } else {
                geoController.text = '';
              }
            });
          },
        ),
        title: Container(
          child: const Text('公开我的地理位置'),
          padding: const EdgeInsets.only(top: 15),
        ),
        subtitle: Text(geoController.text),
      ),
    );
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        _title(),
        _des(),
        _risk(),
        _classification(),
        _tag(),
        _respondDate(),
        _respondTime(),
        _pic(),
        _pics(),
        _email(),
        _tel(),
        _geo(),
        _svg(),
        _captcha(),
        const SizedBox(height: 6.0),
        ElevatedButton(
          child: const Text(
            '提交',
          ),
          onPressed: () {
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  confirm(context, '确定要提交这个能力变现交易吗？'),
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
    } else if ((user!.tel ?? '').isEmpty) {
      return verificationTel(context);
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
          title: Text(widget.paying == 0 ? '创建能力供给交易' : '创建能力需求交易'),
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
