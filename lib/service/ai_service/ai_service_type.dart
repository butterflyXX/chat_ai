import 'package:chat_ai/app_key.dart';
import 'package:chat_ai/generated/l10n.dart';
import 'package:flutter/material.dart';

import 'ai_service_open_ai.dart';

enum AiServiceType {
  agnes(0);

  final int value;
  const AiServiceType(this.value);

  AiServiceBase get service => switch (this) {
    AiServiceType.agnes => AiServiceOpenAi(
      apiKey: agnesAppKey,
      baseUrl: 'https://apihub.agnes-ai.com/v1',
      model: 'agnes-2.5-flash',
    ),
  };

  static AiServiceType fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  String displayName(BuildContext context) => switch (this) {
    AiServiceType.agnes => S.of(context).agnes,
  };
}
