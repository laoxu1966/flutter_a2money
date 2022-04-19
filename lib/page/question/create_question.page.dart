import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';
import '../../common/carousel.dart';

import '../../model/user.model.dart';

import '../../service/user.service.dart';
import '../../service/pref.service.dart';
import '../../service/question.service.dart';
import '../../service/captcha.service.dart';

class CreateQuestionPage extends StatefulWidget {
  @override
  const CreateQuestionPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CreateQuestionPageState();
  }
}

class CreateQuestionPageState extends State<CreateQuestionPage> {
  List<String>? files = [];
  Uint8List bytes = Uint8List.fromList([]);

  User? user;

  bool isComposing = false;

  final formKey = GlobalKey<FormState>();

  final TextEditingController classificationController =
      TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  final TextEditingController picController = TextEditingController();
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

    classificationController.text = '0';

    Map<String, dynamic>? parsedJson = {};
    if (Pref.containsKey('question')) {
      parsedJson = json.decode(Pref.getString('question')!);
    }

    if (parsedJson!.isNotEmpty) {
      classificationController.text = parsedJson['classification'];
      tagController.text = parsedJson['tag'] ?? '';
      titleController.text = parsedJson['title'] ?? '';
      desController.text = parsedJson['des'] ?? '';
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
    picController.dispose();
    captchaController.dispose();

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
      'pic': picController.text,
    };

    await Pref.setString(
      'question',
      json.encode(parsedJson),
    );

    showToast('提交成功。', context);
  }

  void _deleteForm() async {
    Pref.remove('question');

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

    var response = await Provider.of<QuestionService>(context, listen: false)
        .createQuestion(
      titleController.text.trim(),
      desController.text.trim(),
      classificationController.text,
      tagController.text.trim(),
      files!,
      captchaController.text,
      user!.id,
    );

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();
      _deleteForm();
      showToast('提交成功，但目前处于待审查状态，只能在“我发起的能力知乎问题”中查到。', context);
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
          return '正文不能超过510个字';
        } else if (val.isEmpty) {
          return '正文不能为空';
        } else {
          return null;
        }
      },
      onSaved: (val) {
        desController.text = val!.trim();
      },
      decoration: InputDecoration(
        icon: const Icon(Icons.description),
        labelText: '正文',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            desController.clear();
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

  Widget _input() {
    return Column(
      children: <Widget>[
        _title(),
        _des(),
        _classification(),
        _tag(),
        _pic(),
        _pics(),
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
                  confirm(context, '确定要提交这个问题吗？'),
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
      return blocked(context, true);
    } else if ((user!.tel ?? '').isEmpty || (user!.email ?? '').isEmpty) {
      return verificationTel(context, true);
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
          title: const Text('创建能力知乎问题'),
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
