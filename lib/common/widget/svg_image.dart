import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum IconType { asset, network, file, memory, string }

class SvgImage extends StatelessWidget {
  final IconType type;
  final dynamic data;
  final Color? color;
  final double? width;
  final double? height;
  const SvgImage(this.type, {super.key, required this.data, this.color, this.width, this.height});

  factory SvgImage.asset(String asset, {Color? color, double? width, double? height}) {
    return SvgImage(IconType.asset, data: asset, color: color, width: width, height: height);
  }
  factory SvgImage.network(String url, {Color? color, double? width, double? height}) {
    return SvgImage(IconType.network, data: url, color: color, width: width, height: height);
  }
  factory SvgImage.file(File file, {Color? color, double? width, double? height}) {
    return SvgImage(IconType.file, data: file, color: color, width: width, height: height);
  }
  factory SvgImage.memory(Uint8List memory, {Color? color, double? width, double? height}) {
    return SvgImage(IconType.memory, data: memory, color: color, width: width, height: height);
  }
  factory SvgImage.string(String string, {Color? color, double? width, double? height}) {
    return SvgImage(IconType.string, data: string, color: color, width: width, height: height);
  }

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      IconType.asset => _asset(),
      IconType.network => _network(),
      IconType.file => _file(),
      IconType.memory => _memory(),
      IconType.string => _string(),
    };
  }

  Widget _network() {
    return SvgPicture.network(
      data,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      width: width,
      height: height,
    );
  }

  Widget _asset() {
    return SvgPicture.asset(
      data,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      width: width,
      height: height,
    );
  }

  Widget _file() {
    return SvgPicture.file(
      data,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      width: width,
      height: height,
    );
  }

  Widget _memory() {
    return SvgPicture.memory(
      data,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      width: width,
      height: height,
    );
  }

  Widget _string() {
    return SvgPicture.string(
      data,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      width: width,
      height: height,
    );
  }
}
