import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/service/ai_service/ai_service_spark.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:markdown/markdown.dart' as md;

// 自定义代码块构建器，支持语法高亮
class CodeElementBuilder extends MarkdownElementBuilder {
  final bool isDark;
  final AppThemeExtension appTheme;

  CodeElementBuilder({required this.isDark, required this.appTheme});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = element.attributes['class']?.replaceFirst('language-', '') ?? 'dart';
    final code = element.textContent;

    // 根据主题选择高亮主题
    var highlightTheme = isDark ? atomOneDarkTheme : atomOneLightTheme;
    highlightTheme = Map.from(highlightTheme);
    highlightTheme['root'] = TextStyle(color: appTheme.textPrimary, backgroundColor: appTheme.fillsSecondary);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 语言标签
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            alignment: Alignment.centerRight,
            child: Text(language.toLowerCase(), style: TextStyleTheme.medium10.copyWith(color: appTheme.textSecondary)),
          ),
          // 代码内容，使用语法高亮
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              color: Colors.green,
              child: HighlightView(
                code.trimRight(),
                language: language,
                theme: highlightTheme,
                padding: EdgeInsets.zero,
                textStyle: TextStyleTheme.regular12.copyWith(fontFamily: 'monospace', height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatAiWidget extends StatelessWidget {
  final AiMessageModel message;
  const ChatAiWidget({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: context.appTheme.fillsPrimary, borderRadius: BorderRadius.circular(16.w)),
      child: MarkdownBody(
        data: message.message,
        styleSheet: MarkdownStyleSheet(
          // 普通段落
          p: TextStyleTheme.regular14.copyWith(color: context.appTheme.textPrimary, height: 1.6),
          // 标题样式
          h1: TextStyleTheme.semibold20.copyWith(color: context.appTheme.textPrimary),
          h2: TextStyleTheme.semibold18.copyWith(color: context.appTheme.textPrimary),
          h3: TextStyleTheme.semibold16.copyWith(color: context.appTheme.textPrimary),
          // 内联代码样式（用反引号包裹的代码）
          code: TextStyleTheme.regular12.copyWith(
            color: context.appTheme.highlightRed,
            backgroundColor: context.appTheme.fillsSecondary,
            fontFamily: 'monospace',
          ),
          // 代码块样式
          codeblockDecoration: BoxDecoration(
            color: context.appTheme.fillsSecondary,
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(color: context.appTheme.separatorsPrimary, width: 1),
          ),
          codeblockPadding: EdgeInsets.all(12.w),
          // 列表样式
          listBullet: TextStyleTheme.regular14.copyWith(color: context.appTheme.textSecondary),
          // 引用块样式
          blockquoteDecoration: BoxDecoration(
            color: context.appTheme.fillsSecondary,
            borderRadius: BorderRadius.circular(4.w),
            border: Border(
              left: BorderSide(color: context.appTheme.highlightBlue, width: 4.w),
            ),
          ),
          blockquotePadding: EdgeInsets.all(12.w),
          // 链接样式
          a: TextStyleTheme.regular14.copyWith(
            color: context.appTheme.highlightBlue,
            decoration: TextDecoration.underline,
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.px, color: context.appTheme.separatorsSecondary),
            ),
          ),
        ),
        builders: {'pre': CodeElementBuilder(isDark: isDark, appTheme: context.appTheme)},
      ),
    );
  }
}

class ChatUserWidget extends StatelessWidget {
  final AiMessageModel message;
  const ChatUserWidget({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: ColorsTheme.highlightBlue, borderRadius: BorderRadius.circular(16.w)),
          constraints: BoxConstraints(maxWidth: 1.sw * 0.75, minWidth: 1.sw * 0.2),
          child: SelectableText(
            message.message,
            style: TextStyleTheme.regular14.copyWith(color: ColorsTheme.textOndarkPrimary),
          ),
        ),
      ],
    );
  }
}
