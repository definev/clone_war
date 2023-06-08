import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension TextThemeX on TextTheme {
  TextTheme setFontFamily(String fontFamily) => apply(fontFamily: fontFamily);
}

extension ThemeX on Widget {
  Widget get useMaterial3 => Builder(
        builder: (context) => Theme(
          data: context.theme.copyWith(useMaterial3: true),
          child: this,
        ),
      );

  Widget setFontFamily(String fontFamily) => Builder(
        builder: (context) {
          final theme = context.theme;
          return Theme(
            data: theme.copyWith(textTheme: theme.textTheme.setFontFamily(fontFamily)),
            child: this,
          );
        },
      );
}
