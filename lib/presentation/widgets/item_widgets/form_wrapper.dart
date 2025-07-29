import 'package:flutter/material.dart';

class FormWrapper extends StatelessWidget {
  final Widget child;

  const FormWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: FocusScope(autofocus: false, child: child),
    );
  }
}
