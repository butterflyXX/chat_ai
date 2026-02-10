import 'package:bot_toast/bot_toast.dart';

void showToast(String message) {
  BotToast.showText(text: message, duration: const Duration(seconds: 2));
}
