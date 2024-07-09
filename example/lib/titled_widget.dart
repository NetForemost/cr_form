import 'package:flutter/cupertino.dart';

class TitledWidget extends StatelessWidget {
  const TitledWidget({
    this.title,
    Key? key,
    this.child,
    this.titleStyle,
    this.onPressed,
    this.margin,
  }) : super(key: key);

  final String? title;
  final Widget? child;
  final TextStyle? titleStyle;
  final VoidCallback? onPressed;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              margin: margin,
              child: Text(
                title!,
                style: titleStyle ?? const TextStyle(),
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class TitledTextWidget extends StatelessWidget {
  const TitledTextWidget({
    required this.title,
    required this.text,
    Key? key,
    this.titleStyle,
    this.textStyle,
  }) : super(key: key);

  final String title;
  final String text;
  final TextStyle? titleStyle;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TitledWidget(
      title: title,
      titleStyle: titleStyle,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 2,
          right: 2,
          top: 4,
        ),
        child: Text(
          text,
          style: textStyle ?? const TextStyle(),
        ),
      ),
    );
  }
}
