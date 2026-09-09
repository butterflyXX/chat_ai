import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ExtensionInt on num {
  double get px => 1.0 / ScreenUtil().pixelRatio!;
}
