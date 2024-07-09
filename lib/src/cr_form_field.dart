import 'package:cr_form/src/cr_base_text_controller.dart';
import 'package:cr_form/src/cr_form_field_state.dart';
import 'package:flutter/material.dart';

abstract class CRTextFormField extends FormField<String> {
  const CRTextFormField({
    required CRBaseTextController controller,
    required FormFieldBuilder<String> builder,
    required bool enabled,
    Key? key,
    FormFieldValidator<String>? validator,
    AutovalidateMode? autovalidateMode,
    String? initialValue,
    String? restorationId,
    FormFieldSetter<String>? onSaved,
  })  : _controller = controller,
        super(
          builder: builder,
          enabled: enabled,
          key: key,
          validator: validator,
          autovalidateMode: autovalidateMode,
          initialValue: initialValue,
          restorationId: restorationId,
          onSaved: onSaved,
        );

  final CRBaseTextController _controller;

  CRBaseTextController controller() => _controller;
}

abstract class CRBaseTextFieldState extends CRFormFieldState<String> {
  late CRBaseTextController controller;

  // ignore: avoid-returning-widgets
  @override
  CRTextFormField get widget => super.widget as CRTextFormField;

  FocusNode get focusNode => controller.fieldFocus;

  /// Clear value associated with this form field and remove validation error
  ///
  /// For example, you can use it for clear text field from button inside
  /// your custom [CRTextField]:
  /// ```
  /// void _onPressed() {
  ///     state.controller.textEditingController.clear();
  ///     state.clear();
  /// }
  /// ```
  void clear() {
    reset();
    setValue('');
  }
}
