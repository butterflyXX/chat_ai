import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/service/ai_service/ai_service_spark.dart';

class ChatItemAiWidget extends StatelessWidget {
  final AiMessageModel message;
  const ChatItemAiWidget({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: context.appTheme.fillsPrimary, borderRadius: BorderRadius.circular(16.w)),
      child: Text(message.message, style: TextStyleTheme.regular14),
    );
  }
}
