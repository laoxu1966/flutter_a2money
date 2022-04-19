import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';
import '../../common/carousel.dart';

import '../../model/user.model.dart';
import '../../model/question.model.dart';

import '../../service/user.service.dart';
import '../../service/question.service.dart';

class UpdateQuestionPage extends StatefulWidget {
  final int? id;
  final Question? question;
  @override
  const UpdateQuestionPage({Key? key, this.id, this.question})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UpdateQuestionPageState();
  }
}

class UpdateQuestionPageState extends State<UpdateQuestionPage> {
  List<String>? files = [];

  User? user;

  final formKey = GlobalKey<FormState>();

  final TextEditingController classificationController =
      TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  final TextEditingController picController = TextEditingController();

  @override
  void initState() {
    super.initState();

    classificationController.text = widget.question!.classification.toString();
    tagController.text = widget.question!.tag!;
    titleController.text = widget.question!.title;
    desController.text = widget.question!.des;
    picController.text = widget.question!.files!.join(',');
    files = widget.question!.files!;
  }

  @override
  void dispose() {
    classificationController.dispose();
    tagController.dispose();
    titleController.dispose();
    desController.dispose();
    picController.dispose();

    super.dispose();
  }

  void _submitForm() async {
    final FormState form = formKey.currentState!;
    if (!form.validate()) {
      showToast('表单校验未通过', context);
      return;
    }
    form.save();

    var response = await Provider.of<QuestionService>(context, listen: false)
        .updateQuestion(
      widget.id,
      titleController.text.trim(),
      desController.text.trim(),
      classificationController.text,
      tagController.text.trim(),
      files!,
      user!.id,
    );

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();
      showToast('提交成功，请稍后刷新。', context);
    } else if (response?.statusCode == 404) {
      showToast('没有找到数据。', context);
    } else {
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

  Widget _input() {
    return Column(
      children: <Widget>[
        _title(),
        _des(),
        _classification(),
        _tag(),
        _pic(),
        _pics(),
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
                  confirm(context, '确定要修改这个问题吗？'),
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
        title: const Text('修改问题'),
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
