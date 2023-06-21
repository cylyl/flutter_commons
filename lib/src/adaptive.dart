// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DisplayType {
  desktop,
  mobile,
}

const _desktopBreakpoint = 720.0;
const _smallDesktopMaxWidth = 1000.0;

/// Returns the [DisplayType] for the current screen. This app only supports
/// mobile and desktop layouts, and as such we only have one breakpoint.
DisplayType displayTypeOf(BuildContext context) {
  if (MediaQuery.of(context).size.width > _desktopBreakpoint) {
    return DisplayType.desktop;
  } else {
    return DisplayType.mobile;
  }
}

/// Returns a boolean if we are in a display of [DisplayType.desktop]. Used to
/// build adaptive and responsive layouts.
bool isDisplayDesktop(BuildContext context) {
  return displayTypeOf(context) == DisplayType.desktop;
}

/// Returns a boolean if we are in a display of [DisplayType.desktop] but less
/// than 1000 width. Used to build adaptive and responsive layouts.
bool isDisplaySmallDesktop(BuildContext context) {
  return isDisplayDesktop(context) &&
      MediaQuery.of(context).size.width < _smallDesktopMaxWidth;
}

double screenWidthRatio(BuildContext context, double value) {
  return MediaQuery.of(context).size.width * value;
}

double screenHeightRatio(BuildContext context, double value) {
  return MediaQuery.of(context).size.height * value;
}

bool isScreenVertical(BuildContext context) {
  return MediaQuery.of(context).size.height < MediaQuery.of(context).size.width;
}

bool isScreenHorizontal(BuildContext context) {
  return !isScreenVertical(context);
}

double dpi(BuildContext context, double value) {
  return MediaQuery.of(context).devicePixelRatio * value;
}

double aWidth(BuildContext context, double value) {
  return screenWidthMax(context) > (isScreenHorizontal(context) ? 1080 : 720)
      ? (screenWidthMax(context) /
          (isScreenHorizontal(context) ? 1080 : 720) *
          value)
      : value > screenWidthMax(context)
          ? (screenWidthMax(context) * .9)
          : value;
}

double aHeight(BuildContext context, double value) {
  return screenHeightMax(context) > (!isScreenHorizontal(context) ? 1080 : 720)
      ? (screenHeightMax(context) /
          (!isScreenHorizontal(context) ? 1080 : 720) *
          value)
      : value > screenHeightMax(context)
          ? (screenHeightMax(context) * .8)
          : value;
}

double screenWidthMax(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double screenHeightMax(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double devicePixelRatio(BuildContext context) {
  return MediaQuery.of(context).devicePixelRatio;
}

double textSizeX(BuildContext context) {
  double factor = devicePixelRatio(context);
  if (factor > 2) factor = 1;
  return factor /
      ((720 * 1080) /
          ((screenWidthRatio(context, 1) * screenHeightRatio(context, 1))) /
          devicePixelRatio(context));
}

double liveviewLeftBarWidthLargeRadio = 0.35;
double liveviewLeftBarWidthSmallRadio = 0.18;

/// Using letter spacing in Flutter for Web can cause a performance drop,
/// see https://github.com/flutter/flutter/issues/51234.
double letterSpacingOrNone(double letterSpacing) =>
    kIsWeb ? 0.0 : letterSpacing;

int centerFlex(BuildContext context) {
  return screenWidthMax(context) ~/
      (isDisplayDesktop(context)
          ? isDisplaySmallDesktop(context)
              ? 300
              : 400
          : 186);
}

bool isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

int rotateTabMaxWidth(BuildContext context) {
  return screenWidthMax(context) ~/ (isDisplayDesktop(context) ? 6.0 : 2.0);
}

Size centerSize(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return (isDisplayDesktop(context))
      ? Size((size.width * (centerFlex(context) / 4 /*flex*/)), size.height)
      : size;
}
