import 'package:cr_form/cr_form.dart';
import 'package:flutter/material.dart';

typedef AsyncFormFieldBuilder<T> = Widget Function(
  Future<void> Function() asyncCallbackWithUpdate,
  T? value,
);

typedef AsyncCallback<T> = Future<T?> Function();

/// Allows you to create validated custom form fields with asynchronous update.
///
/// To the [asyncCallback] parameter you must specify the asynchronous method
/// after the execution of which the widget update is required.
/// Inside [AsyncFormFieldBuilder] you can call [asyncCallbackWithUpdate]
/// calling your asynchronous method and then updating widget's value.
///
/// Example of use:
/// ```dart
///
/// CRAsyncFormField<Color>(
///   initialValue: null,
///   asyncCallback: _openChooseColorPage,
///   builder: (asyncCallbackWithUpdate, Color? color) {
///     return ElevatedButton(
///         onPressed: asyncCallbackWithUpdate,
///         child: const Text('Choose color'));
///   },
///   validator: (Color? color) =>
///       color == null ? 'Color is required' : null,
/// ),
///
/// ...
///
/// Future<Color?> _openChooseColorPage() async {
///   final color = await Navigator.push(
///     context,
///     MaterialPageRoute(builder: (context) => const ChooseColorPage()),
///   );
///   return color;
/// }
///
/// ```

class CRAsyncFormField<T extends Object?> extends FormField<T> {
  CRAsyncFormField({
    required AsyncCallback<T> asyncCallback,
    required AsyncFormFieldBuilder<T> builder,
    T? initialValue,
    FormFieldValidator<T>? validator,
    Key? key,
  }) : super(
          key: key,
          validator: validator,
          initialValue: initialValue,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<T> state) {
            return builder(
              () async => state.didChange(await asyncCallback()),
              state.value,
            );
          },
        );

  @override
  FormFieldState<T> createState() => CRAsyncFormFieldState<T>();
}

class CRAsyncFormFieldState<T> extends CRFormFieldState<T> {
  // ignore: avoid-returning-widgets
  @override
  FormField<T> get widget => super.widget;
}
