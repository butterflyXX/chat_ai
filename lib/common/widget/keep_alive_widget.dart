import 'package:flutter/cupertino.dart';

class CIKeepAliveWidget extends StatefulWidget {
  const CIKeepAliveWidget({super.key, required this.child});
  final Widget child;

  @override
  State<CIKeepAliveWidget> createState() => _CIKeepAliveWidgetState();
}

class _CIKeepAliveWidgetState extends State<CIKeepAliveWidget> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
