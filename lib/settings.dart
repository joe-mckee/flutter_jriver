import 'mc_server.dart';
import 'server_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<SettingsScreen> {
  final _formKey = GlobalKey();
  String? accessKey;
  String? username;
  String? password;

  final acController = TextEditingController();
  final userController = TextEditingController();
  final passController = TextEditingController();

  MCServer? server;

  String? accessKeyValidator(value) {
    final alpha = RegExp(r'^[a-zA-Z]{6}$');
    if (value == null || value.isEmpty) {
      return 'Please enter server access key';
    }
    if (!alpha.hasMatch(value)) {
      return 'Access key must be six letters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Builder(
            builder: (context) => Form(
                  key: _formKey,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: Column(children: [
                        PlatformTextFormField(
                          hintText: 'Access Key',
                          controller: acController,
                          validator: (value) {
                            final message = accessKeyValidator(value);
                            return message;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onSaved: (value) {
                            accessKey = value;
                          },
                        ),
                        PlatformTextFormField(
                          hintText: 'Username',
                          controller: userController,
                          onSaved: (value) {
                            username = value;
                          },
                        ),
                        PlatformTextFormField(
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          hintText: 'Password',
                          controller: passController,
                          onSaved: (value) {
                            password = value;
                          },
                        ),
                        PlatformElevatedButton(
                          child: const Text('Connect'),
                          onPressed: () {
                            final accessKey = acController.text;
                            final userName = userController.text;
                            final password = passController.text;

                            server = MCServer(accessKey, userName, password);
                            server?.connect();

                            if (server?.status == ServerStatus.notConnected) {
//                              if (getServerInfo(server, ))
                            }

                            print('joe was here');
                          },
                        ),
                      ])),
                )));
  }
}
