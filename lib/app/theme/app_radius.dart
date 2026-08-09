import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  AppRadius._();

  static const double small = 8;
  static const double medium = 14;
  static const double large = 20;
  static const double xLarge = 28;
  static const double pill = 999;

  static const BorderRadius borderSmall = BorderRadius.all(
    Radius.circular(small),
  );

  static const BorderRadius borderMedium = BorderRadius.all(
    Radius.circular(medium),
  );

  static const BorderRadius borderLarge = BorderRadius.all(
    Radius.circular(large),
  );

  static const BorderRadius borderXLarge = BorderRadius.all(
    Radius.circular(xLarge),
  );
}
