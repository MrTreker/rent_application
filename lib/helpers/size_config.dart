import 'package:flutter/material.dart';

extension TextSize on double {
  double toAdaptive(BuildContext context) {
    MediaQueryData _mediaQueryData = MediaQuery.of(context);
    double w = _mediaQueryData.size.width / 100;
    // double h = _mediaQueryData.size.height;
    double sizeTextLayot = this / (414 / 100);
    double sizedText = sizeTextLayot * w;
    return sizedText;
  }
}
