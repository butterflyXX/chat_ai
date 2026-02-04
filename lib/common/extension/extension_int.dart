import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ExtensionInt on int {
  double get px => 1.0 / ScreenUtil().pixelRatio!;
}
