Form with the ability to autoscroll to an invalid field. 

## Getting Started

Add plugin to your project:
```yaml
    dependencies:
      git:
        url: https://igmar:glpat-CPcq3MxYGVm2n2i2t-gZ@gitlab.cleveroad.com/internal/flutter/bootstrap/cr_form
        ref: 0.0.9
```

## Components

### Class `CRForm` 
Class in which to wrap text forms. Works exactly the same as `Form`.

The `CRForm` itself needs to be wrapped in a `SingleChildScrollView`.

```dart
body: SingleChildScrollView(
  controller: _scrollController,
  child: CRForm(
    controller: _formController,
    child: Column(
      children: [
        CRTextField(
```

To validate fields call `await _formController.validate()`.

### Custom form field

For creating your own fields that need to validate you should inherit widget from:
* If field has text input - `CRTextFormField`
* If simple widget (e.g. Checkbox) - `FormField<T>`

Every custom widget shoud have state class. So need to inherit state from:
* If field has text input - `CRBaseTextFieldState`

Also need to override `widget` field that returns widget class:
```dart
class CRTextField extends CRTextFormField {
...

  @override
  FormFieldState<String> createState() => CRTextFieldState();
}

class CRTextFieldState extends CRBaseTextFieldState {
  @override
  CRTextField get widget => super.widget as CRTextField;
...
```

* If simple widget (e.g. Checkbox) - `CRFormFieldState<T>`

**NOTE!** We needn't to describe build logic in `build`. Instead use `builder` method from constructor 
to build form field with error label showing.

```dart
// constructor
...
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
...
```

`FormFieldState` contains state of field: field value (entered text), error text. Also contains `didChange` method to updating state of field (e.g. checkbox check by user or text change in text form field):

```dart
// CRTextField. builder method
...
child: TextField(
    onChanged: (value) {
        state.didChange(value);
        onChanged?.call(value);
    },
...
```


