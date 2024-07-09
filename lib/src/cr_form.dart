import 'dart:async';

import 'package:cr_form/src/cr_form_field.dart';
import 'package:cr_form/src/utils/keyboard_listener.dart' as kl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:render_metrics/render_metrics.dart';

// ignore: unused_field
enum _CRFormAction { validate }

class CRFormController extends ValueNotifier<_CRFormAction?> {
  CRFormController() : super(null);

  Future<bool> Function()? _onValidate;

  @override
  void dispose() {
    _onValidate = null;
    super.dispose();
  }

  Future<bool> validate() {
    return _onValidate?.call() ?? Future.value(false);
  }

  // ignore: use_setters_to_change_properties
  void _setOnValidate(Future<bool> Function() method) {
    _onValidate = method;
  }
}

class CRFormScope extends InheritedWidget {
  const CRFormScope({
    required Widget child,
    required CRFormState formState,
    required RenderParametersManager renderManager,
    Key? key,
  })  : _formState = formState,
        _manager = renderManager,
        super(
          key: key,
          child: child,
        );

  final CRFormState _formState;
  final RenderParametersManager _manager;

  RenderParametersManager get renderParametersManager => _manager;

  static CRFormScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CRFormScope>();
  }

  /// updating doesn't needed because this InheritedWidget only stores
  /// renderParametersManager field and no contains any logic
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class CRForm extends StatefulWidget {
  const CRForm({
    required this.child,
    required this.controller,
    this.onChanged,
    Key? key,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.ease,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.scrollOffset = 0,
    this.debugMode = false,
    this.autoscroll = true,
    this.recalculateFieldsBeforeValidations = false,
  }) : super(key: key);

  final CRFormController controller;
  final Widget child;

  /// Called when one of the form fields changes.
  ///
  /// Make sure you call [FormFieldState.didChange] in your widget.
  ///
  /// And if you store some custom states inside [CRFormFieldState] and want
  /// run [onChanged] on those states changes, call [FormFieldState.didChange]
  /// in your field state too.
  /// <br>
  /// <br>
  /// For example in this way for widget inherited from [FormField]:
  /// ```
  /// Checkbox(
  ///   value: state.value,
  ///   onChanged: (value) {
  ///     state.didChange(value);
  ///   },
  /// )
  /// ```
  ///
  /// Where [state] in [FormFieldState].
  final VoidCallback? onChanged;

  final Duration animationDuration;
  final Curve animationCurve;
  final CrossAxisAlignment crossAxisAlignment;
  final double scrollOffset;

  /// autoscroll to first invalid field after validation checking
  final bool autoscroll;

  /// show keyboard line
  final bool debugMode;
  final AutovalidateMode autovalidateMode;
  final bool recalculateFieldsBeforeValidations;

  static CRFormState? of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CRFormScope>();

    return scope?._formState;
  }

  @override
  State<CRForm> createState() => CRFormState();
}

class CRFormState extends State<CRForm> {
  final _formKey = GlobalKey<FormState>();
  final _renderManager = RenderParametersManager();
  final _overlayId = 'overlay';

  final _fields = <FormFieldState<dynamic>>{};
  final _idsFields = <MapEntry<String, FormFieldState>>[];

  late kl.KeyboardListener _keyboardListener;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _overlayEntry = OverlayEntry(builder: _buildOverlay);
      Overlay.of(context)?.insert(_overlayEntry!);
      _keyboardListener = kl.KeyboardListener()
        ..addListener(onChange: _keyboardHandle);
      recalculateFieldIds();
    });

    widget.controller._setOnValidate(validateAll);
  }

  @override
  void dispose() {
    // dispose for overlayEntry should only be called by the object's owner;
    // typically the Navigator owns a route and so will call this method when the route is removed
    // we need only call remove method, for clean all links
    _overlayEntry?.remove();
    _overlayEntry = null;
    _keyboardListener.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => recalculateFieldIds(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CRFormScope(
      renderManager: _renderManager,
      formState: this,
      child: Form(
        key: _formKey,
        autovalidateMode: widget.autovalidateMode,
        onChanged: widget.onChanged,
        child: widget.child,
      ),
    );
  }

  void register(FormFieldState state) {
    _fields.add(state);
  }

  void unregister(FormFieldState state) {
    _fields.remove(state);
  }

  /// Call this to validating your form
  Future<bool> validateAll() async {
    if (widget.recalculateFieldsBeforeValidations) {
      recalculateFieldIds();
    }

    final fieldsIsValid = _formKey.currentState?.validate() ?? false;

    // You need to find the first invalid field first.
    // We will scroll to him
    String? firstInvalidId;
    for (final entry in _idsFields) {
      final valid = entry.value.isValid;

      if (!valid && firstInvalidId == null) {
        firstInvalidId = entry.key;
        break;
      }
    }

    // here we retrieve render information of first invalid field
    // 1. Get the difference from invalid field to overlay widget (which positioned on bottom)
    // 2. Do scroll field to overlay widget
    // 3. If field is text field - request keyboard
    if (firstInvalidId != null && widget.autoscroll) {
      final state = _idsFields
          .firstWhere((element) => element.key == firstInvalidId)
          .value;
      final diff = _renderManager.getDiffById(firstInvalidId, _overlayId);
      if (diff != null) {
        final dy = diff.diffBottomToTop + widget.scrollOffset;
        await _doScroll(dy);
      } else if (kDebugMode) {
        print(
          'cr_form: Failed to calculate difference to first invalid field.\n'
          'Try to enable fields recalculation before validation with \n'
          'parameter [recalculateFieldsBeforeValidations] of [CRForm].',
        );
      }
      if (state is CRBaseTextFieldState) {
        state.focusNode.requestFocus();
      }
    }

    return fieldsIsValid;
  }

  /// Method for retrieving fields render metrics
  /// Every found metrics have its id that will saved in list
  void recalculateFieldIds() {
    final fields = <String, FormFieldState>{};

    // every validable widget must contains RenderMetricsObject on the root
    // for detecting self metrics in CRForm
    for (final fieldState in _fields) {
      fieldState.context.visitChildElements((element) {
        if (element.widget is RenderMetricsObject) {
          final widget = element.widget as RenderMetricsObject<String>;
          final id = widget.id;
          fields[id] = fieldState;
        }
      });
    }

    // sorting by position on screen
    // top widget in beginning
    final sortedEntries = _sortByPosition(fields);
    _idsFields
      ..clear()
      ..addAll(sortedEntries);
  }

  /// Method for sorting fields metrics by position on the screen
  /// Top widgets will be at the beginning of the list
  List<MapEntry<String, FormFieldState<dynamic>>> _sortByPosition(
    Map<String, FormFieldState<dynamic>> fields,
  ) {
    return fields.entries.toList()
      ..sort((a, b) {
        final renderDataA = _renderManager.getRenderData(a.key);
        final renderDataB = _renderManager.getRenderData(b.key);

        // ignore: prefer-conditional-expressions
        if (renderDataA != null && renderDataB != null) {
          return renderDataA.yTop > renderDataB.yTop ? 1 : -1;
        } else {
          return 0;
        }
      });
  }

  /// Scrolling with scrollOffset
  /// First, we get Scrollable.of(context) to retrieve the current position
  /// Second, we scroll on passed offset
  Future<void> _doScroll(double scrollOffset) async {
    final controller = Scrollable.of(context);
    if (controller != null) {
      final offset = controller.position.pixels;
      var newOffset = controller.position.pixels + scrollOffset;

      if (scrollOffset < 0) {
        final bound = offset - scrollOffset.abs();
        // ignore: prefer-conditional-expressions
        if (bound >= 0) {
          newOffset = bound;
        } else {
          newOffset = 0;
        }
      }

      await controller.position.animateTo(
        newOffset,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }
  }

  Widget _buildOverlay(BuildContext context) {
    final bottomInsetPadding = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: <Widget>[
        Positioned(
          bottom: bottomInsetPadding,
          left: 0,
          right: 0,
          child: RenderMetricsObject(
            id: _overlayId,
            manager: _renderManager,
            child: _InvisibleOverlay(
              debugMode: widget.debugMode,
            ),
          ),
        ),
      ],
    );
  }

  void _keyboardHandle(bool _) {
    _overlayEntry?.markNeedsBuild();
  }
}

class _InvisibleOverlay extends StatelessWidget {
  const _InvisibleOverlay({
    Key? key,
    this.debugMode = false,
  }) : super(key: key);

  final bool debugMode;

  @override
  Widget build(BuildContext context) {
    return debugMode
        ? Container(
            height: 10,
            width: 10,
            color: Colors.green,
          )
        : const SizedBox();
  }
}
