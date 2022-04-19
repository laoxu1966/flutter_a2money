import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../service/user.service.dart';

class UpdateProfilePage extends StatefulWidget {
  final Map<String, dynamic>? profile;
  @override
  const UpdateProfilePage({Key? key, this.profile}) : super(key: key);

  @override
  UpdateProfilePageState createState() => UpdateProfilePageState();
}

class UpdateProfilePageState extends State<UpdateProfilePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController avatarController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.profile!.isNotEmpty) {
      avatarController.text = widget.profile!['avatar'] ?? '';
      displayNameController.text = widget.profile!['displayName'] ?? '';
      descriptionController.text = widget.profile!['description'] ?? '';
    }
  }

  @override
  void dispose() {
    avatarController.dispose();
    displayNameController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  void _submitForm() async {
    final FormState form = formKey.currentState as FormState;

    if (!form.validate()) {
      showToast('表单校验未通过', context);
      return;
    }

    form.save();

    widget.profile!['avatar'] = avatarController.text.trim();
    widget.profile!['displayName'] = displayNameController.text.trim();
    widget.profile!['description'] = descriptionController.text.trim();

    var response =
        await context.read<UserService>().updateProfile(widget.profile!);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();

      showToast('提交成功。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
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
              final ImageCropper imageCropper = ImageCropper();
              File croppedFile = (await imageCropper.cropImage(
                sourcePath: file.path,
                compressQuality: 60,
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,
                ],
                androidUiSettings: const AndroidUiSettings(
                    toolbarTitle: 'Cropper',
                    initAspectRatio: CropAspectRatioPreset.original,
                    lockAspectRatio: false),
              ))!;

              avatarController.text = croppedFile.path;
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
              final ImageCropper imageCropper = ImageCropper();
              File croppedFile = (await imageCropper.cropImage(
                sourcePath: file.path,
                compressQuality: 60,
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,
                ],
                androidUiSettings: const AndroidUiSettings(
                    toolbarTitle: 'Cropper',
                    initAspectRatio: CropAspectRatioPreset.original,
                    lockAspectRatio: false),
              ))!;

              avatarController.text = croppedFile.path;
            }
            break;

          default:
            showToast(selected.toString(), context);
            break;
        }
      },
    );
  }

  Widget _input() {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: avatarController,
          readOnly: true,
          textInputAction: TextInputAction.next,
          validator: (val) {
            return null;
          },
          onSaved: (val) {
            avatarController.text = val!;
          },
          decoration: InputDecoration(
            icon: const Icon(Entypo.emoji_happy),
            labelText: '用户头像',
            suffixIcon: _pickButton(),
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.only(left: 30.0),
          child: avatarController.text.isNotEmpty
              ? getPicture(avatarController.text)
              : Container(),
        ),
        TextFormField(
          controller: displayNameController,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.length > 45) {
              return '长度不能大于45。';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            displayNameController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(Feather.user),
            labelText: '显示名称',
          ),
        ),
        TextFormField(
          controller: descriptionController,
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val!.length > 60) {
              return '长度不能大于60。';
            } else {
              return null;
            }
          },
          onSaved: (val) {
            descriptionController.text = val!;
          },
          decoration: const InputDecoration(
            icon: Icon(MaterialIcons.description),
            labelText: '自我描述',
          ),
        ),
        const SizedBox(height: 15.0),
        ElevatedButton(
          child: const Text(
            '修改用户资料',
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
        title: const Text('修改用户资料'),
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
