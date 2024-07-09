import 'package:cr_form/src/cr_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:render_metrics/render_metrics.dart';
import 'package:uuid/uuid.dart';

class CRFormFieldState<T> extends FormFieldState<T> {
  final id = const Uuid().v4();

  @override
  void deactivate() {
    CRForm.of(context)?.unregister(this);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    CRForm.of(context)?.register(this);

    final formScope = CRFormScope.of(context);

    return formScope != null
        ? RenderMetricsObject(
            id: id,
            manager: formScope.renderParametersManager,
            child: super.build(context),
          )
        : super.build(context);
  }
}