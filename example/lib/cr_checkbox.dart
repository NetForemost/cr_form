import 'package:cr_form/cr_form.dart';
import 'package:flutter/material.dart';

class CRCheckbox extends FormField<bool> {
  CRCheckbox({
    Key? key,
    FormFieldValidator<bool>? validator,
    bool? initialValue,
    String? text,
  }) : super(
          key: key,
          validator: validator,
          initialValue: initialValue,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<bool> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: state.value,
                      onChanged: (value) {
                        state.didChange(value);
                      },
                    ),
                    if (text != null) Text(text),
                  ],
                ),
                if (state.hasError)
                  Text(
                    state.errorText ?? '',
                    style: const TextStyle(
                      color: Colors.red
                    ),
                  ),
              ],
            );
          },
        );

  @override
  FormFieldState<bool> createState() => CRCheckboxState();
}

class CRCheckboxState extends CRFormFieldState<bool> {
  // ignore: avoid-returning-widgets
  @override
  FormField<bool> get widget => super.widget;
}
