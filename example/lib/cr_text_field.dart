import 'package:cr_form/cr_form.dart';
import 'package:example/titled_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

class CRTextController extends CRBaseTextController {
  CRTextController({
    String? value,
    TextEditingController? ctrl,
  }) {
    if (value != null) {
      ctrl?.text = value;
    }
    textEditingController = ctrl ?? TextEditingController(text: value);
  }

  late final TextEditingController textEditingController;

  String? _errorText;

  String get text => textEditingController.text;

  // ignore: unnecessary_getters_setters
  String? get errorText => _errorText;

  set errorText(String? error) => _errorText = error;

  bool get hasError => errorText != null;
}

class CRTextField extends CRTextFormField {
  CRTextField({
    required CRTextController controller,
    Key? key,
    FormFieldValidator<String>? validator,
    bool autocorrect = false,
    bool obscureText = false,
    String? prefixText,
    String? hintText,
    Widget? prefixIcon,
    String counterText = '',
    AutovalidateMode? autovalidateMode = AutovalidateMode.onUserInteraction,
    int errorMaxLines = 2,
    String? title,
    Iterable<String>? autofillHints,
    final Function(String)? onChanged,
    int maxLength = kMaxFieldLength,
    TextInputType? keyboardType,
    TextStyle prefixStyle = const TextStyle(),
    TextStyle hintStyle = const TextStyle(),
    EdgeInsets scrollPadding = const EdgeInsets.all(20),
    final List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    bool enabled = true,
  })  : _controller = controller,
        super(
          controller: controller,
          key: key,
          validator: validator,
          autovalidateMode: autovalidateMode,
          enabled: enabled,
          builder: (state) {
            final hasPrefix = prefixText != null || prefixIcon != null;
            final hasError = state.hasError || controller.errorText != null;
            final errorText = controller.errorText ?? state.errorText;

            return TitledWidget(
              title: title,
              margin: const EdgeInsets.only(left: 8, bottom: 4),
              child: TextField(
                scrollPadding: scrollPadding,
                controller: controller.textEditingController,
                focusNode: controller.fieldFocus,
                onChanged: (value) {
                  state.didChange(value);
                  onChanged?.call(value);
                },
                obscuringCharacter: '*',
                inputFormatters: inputFormatters,
                autocorrect: autocorrect,
                obscureText: obscureText,
                textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.left,
                textInputAction: textInputAction,
                autofillHints: autofillHints,
                maxLength: maxLength,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  enabledBorder: textFieldBorder,
                  disabledBorder: textFieldBorder,
                  focusedBorder: textFieldBorder,
                  errorBorder: errorTextFieldBorder,
                  focusedErrorBorder: errorTextFieldBorder,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  fillColor: Colors.black12,
                  filled: true,
                  // isDense: true,
                  isCollapsed: hasPrefix,
                  contentPadding: hasPrefix ? EdgeInsets.zero : null,
                  prefixIconConstraints: hasPrefix
                      ? const BoxConstraints(
                          minWidth: kMinInteractiveDimension,
                          minHeight: kMinInteractiveDimension,
                          maxHeight: kMinInteractiveDimension,
                          maxWidth: kMinInteractiveDimension,
                        )
                      : null,
                  hintText: hintText,
                  hintStyle: hintStyle,
                  counterText: counterText,
                  errorMaxLines: errorMaxLines,
                  helperText: '',
                  errorText: hasError ? errorText : null,
                  prefixIcon: hasPrefix
                      ? Center(
                          child: prefixText != null
                              ? Text(
                                  prefixText,
                                  style: prefixStyle,
                                  textAlign: TextAlign.center,
                                )
                              : prefixIcon,
                        )
                      : null,
                ),
              ),
            );
          },
        );

  final CRTextController _controller;

  @override
  CRTextController controller() => _controller;

  @override
  FormFieldState<String> createState() => CRTextFieldState();
}

class CRTextFieldState extends CRBaseTextFieldState {
  // ignore: avoid-returning-widgets
  @override
  CRTextField get widget => super.widget as CRTextField;

  @override
  // TODO: implement controller
  CRTextController get controller => widget.controller();

  @override
  bool get isValid => super.isValid && !controller.hasError;

  @override
  bool validate() {
    if (controller.hasError) {
      return false;
    }

    return super.validate();
  }
}
