import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'constant.dart';

import '../page/user/update_email.page.dart';
import '../page/user/update_tel.page.dart';

class Panel {
  Panel({required this.header, this.inputs, this.isExpanded = false});

  String header;
  Widget? inputs;
  bool isExpanded;
}

getPicture(String? url) {
  if (url!.startsWith("mock/") ||
      url.startsWith("ability/") ||
      url.startsWith("question/") ||
      url.startsWith("avatar/")) {
    return CachedNetworkImage(
      imageUrl: endPoint + '/' + url,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  if (url.startsWith("data:image/png;base64")) {
    String base64Img = url.split(',')[1];
    Uint8List decoded = base64Decode(base64Img);

    return Image.memory(
      decoded,
      fit: BoxFit.cover,
      errorBuilder: (
        BuildContext context,
        Object exception,
        StackTrace? stackTrace,
      ) =>
          const Icon(Icons.error),
    );
  }

  if (url.startsWith("/storage/") || url.startsWith("/data/")) {
    File file = File(url.replaceAll('"', ''));
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (
        BuildContext context,
        Object exception,
        StackTrace? stackTrace,
      ) =>
          const Icon(Icons.error),
    );
  }

  return const Icon(Icons.error);
}

getAvatar(String? url) {
  if (url!.startsWith("mock/avatar/") || url.startsWith("avatar/")) {
    return CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(
        endPoint + '/' + url,
        errorListener: () => const Icon(Icons.error),
      ),
      onBackgroundImageError: (exception, stackTrace) => false,
    );
  }

  if (url.startsWith("data:image/png;base64")) {
    String base64Img = url.split(',')[1];
    Uint8List decoded = base64Decode(base64Img);

    return CircleAvatar(
      backgroundImage: MemoryImage(
        decoded,
      ),
      onBackgroundImageError: (exception, stackTrace) => false,
    );
  }

  if (url.startsWith("/storage/") || url.startsWith("/data/")) {
    File file = File(url.replaceAll('"', ''));

    return CircleAvatar(
      backgroundImage: FileImage(
        file,
      ),
      onBackgroundImageError: (exception, stackTrace) => false,
    );
  }

  return CircleAvatar(
    backgroundImage: const AssetImage(
      'assets/image/error.png',
    ),
    onBackgroundImageError: (exception, stackTrace) => false,
  );
}

showToast(message, context) {
  return Flushbar(
    message: message,
    title: '??????',
    duration: const Duration(seconds: 3),
    icon: Icon(
      Icons.check,
      color: Theme.of(context).colorScheme.secondary,
    ),
  )..show(context);
}

anonymous(context, bar) {
  return Scaffold(
    appBar: bar
        ? AppBar(
            title: const Text('?????????????????????'),
          )
        : null,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            '?????????????????????',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6.0),
          ElevatedButton(
            child: const Text(
              '??????',
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/signin', (router) => true);
            },
          ),
        ],
      ),
    ),
  );
}

blocked(context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('???????????????????????????'),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            '??????????????????????????????\r\n???????????????????????????',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6.0),
          ElevatedButton(
            child: const Text(
              '????????????????????????',
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/signin', (router) => true);
            },
          ),
        ],
      ),
    ),
  );
}

verificationEmail(context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('????????????????????????????????????'),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            '????????????????????????????????????',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6.0),
          ElevatedButton(
            child: const Text(
              '??????',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpdateEmailPage(
                    email: '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

verificationTel(context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('??????????????????????????????'),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            '??????????????????????????????',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6.0),
          ElevatedButton(
            child: const Text(
              '??????',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpdateTelPage(
                    tel: '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

confirm(context, String des) {
  return AlertDialog(
    title: Text(
      des,
      style: const TextStyle(
        color: Colors.grey,
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: const Text('??????'),
        onPressed: () {
          Navigator.pop(context, ConfirmDialogAction.CANCEL);
        },
      ),
      TextButton(
        child: const Text('??????'),
        onPressed: () {
          Navigator.pop(context, ConfirmDialogAction.OK);
        },
      )
    ],
  );
}

memo(context, String initialValue) {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String inputValue = '';

  return AlertDialog(
    title: const Text(
      '????????????',
    ),
    content: Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        child: TextFormField(
          initialValue: initialValue,
          maxLength: 15,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '??????',
          ),
          onSaved: (val) {
            inputValue = val!.trim();
          },
          validator: (val) {
            if (val!.trim().length > 15) {
              return '??????????????????15??????';
            } else if (val.isEmpty) {
              return '??????????????????';
            } else {
              return null;
            }
          },
        ),
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: const Text('??????'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      TextButton(
        child: const Text('??????'),
        onPressed: () {
          final FormState form = formKey.currentState!;
          if (!form.validate()) {
            showToast('?????????????????????', context);
            return;
          }
          form.save();

          Navigator.pop(context, inputValue);
        },
      )
    ],
  );
}

List<InlineSpan> highlight(
  String sub,
  List<String> terms,
  TextStyle textStyle,
  TextStyle highlighttextStyle,
) {
  final subLC = sub.toLowerCase();

  List<InlineSpan> spans = [];

  int start = 0;
  int index = 0;
  while (index < subLC.length) {
    int iNearest = -1;
    int indexNearest = double.maxFinite.toInt();

    for (int i = 0; i < terms.length; i++) {
      int indexof = subLC.indexOf(terms[i], index);
      if (indexof >= 0 && indexof < indexNearest) {
        iNearest = i;
        indexNearest = indexof;
      }
    }

    if (iNearest >= 0) {
      if (start < indexNearest) {
        spans.add(
          TextSpan(
            text: sub.substring(start, indexNearest),
            style: textStyle,
          ),
        );
        start = indexNearest;
      }

      int termLen = terms[iNearest].length;
      spans.add(
        TextSpan(
          text: sub.substring(start, indexNearest + termLen),
          style: highlighttextStyle,
        ),
      );

      start = index = indexNearest + termLen;
    } else {
      spans.add(
        TextSpan(
          text: sub.substring(start, subLC.length),
          style: textStyle,
        ),
      );

      break;
    }
  }

  return spans;
}
