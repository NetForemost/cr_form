import 'dart:developer';

import 'package:cr_form/cr_form.dart';
import 'package:example/cr_checkbox.dart';
import 'package:example/cr_text_field.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formController = CRFormController();
  final _ctrl1 = CRTextController();
  final _ctrl2 = CRTextController();
  final _ctrl3 = CRTextController();

  var _fieldChangesCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _fieldChangesCounter > 0
            ? Text('$_fieldChangesCounter changes')
            : null,
        actions: [
          IconButton(
            onPressed: () async {
              log('valid = ${await _formController.validate()}');
            },
            icon: const Icon(Icons.check_circle_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        primary: false,
        child: CRForm(
          controller: _formController,
          debugMode: true,
          onChanged: _onFieldChanged,
          child: Column(
            children: [
              const SizedBox(height: 200),
              CRTextField(
                controller: _ctrl1,
                title: 'Test field',
                validator: (name) {
                  if (name?.isEmpty ?? true) {
                    return 'Cannot be empty';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 200),
              CRTextField(
                controller: _ctrl2,
                title: 'Test field',
                validator: (name) {
                  if (name?.isEmpty ?? true) {
                    return 'Cannot be empty';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 200),
              CRTextField(
                controller: _ctrl3,
                title: 'Test field',
                validator: (name) {
                  if (name?.isEmpty ?? true) {
                    return 'Cannot be empty';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 500),
              Row(
                children: [
                  Expanded(
                    child: CRCheckbox(
                      text: 'sasas',
                      initialValue: false,
                      validator: (value) {
                        if (!value!) return 'ololo';
                        return null;
                      },
                    ),
                  ),
                  Expanded(
                    child: CRCheckbox(
                      text: 'sasas',
                      initialValue: false,
                      validator: (value) {
                        if (!value!) return 'ololo';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              ///Complete button
              ElevatedButton(
                onPressed: () async {
                  if (await _formController.validate()) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Valid!')));
                  }
                },
                child: const Text('Validate'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onFieldChanged() {
    setState(() {
      _fieldChangesCounter++;
    });
  }
}
