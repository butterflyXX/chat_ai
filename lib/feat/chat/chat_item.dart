import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/service/ai_service/ai_service_base.dart';
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

class ChatAiWidget extends StatefulWidget {
  final AiMessageModel message;
  const ChatAiWidget({required this.message, super.key});

  @override
  State<ChatAiWidget> createState() => _ChatAiWidgetState();
}

class _ChatAiWidgetState extends State<ChatAiWidget> {
  bool _thinkingExpanded = true;
  final _thinkingScrollController = ScrollController();

  // 字号 12，行高 1.6，5 行 + 上下各 10 padding
  static const _kThinkingLineHeight = 1.6;
  static const _kThinkingFontSize = 12.0;
  static const _kThinkingMaxLines = 5;

  double get _thinkingMaxHeight =>
      _kThinkingFontSize.w * _kThinkingLineHeight * _kThinkingMaxLines + 20.w;

  @override
  void didUpdateWidget(ChatAiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当正式回答开始输出时，自动收起思考过程
    if (oldWidget.message.message.isEmpty && widget.message.message.isNotEmpty) {
      setState(() => _thinkingExpanded = false);
    }
    // 思考内容更新时，自动滚到底部显示最新内容
    if (_thinkingExpanded &&
        widget.message.reasoningContent != oldWidget.message.reasoningContent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_thinkingScrollController.hasClients) {
          _thinkingScrollController.jumpTo(
            _thinkingScrollController.position.maxScrollExtent,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _thinkingScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appTheme = context.appTheme;
    final hasReasoning = widget.message.reasoningContent.isNotEmpty;
    final isThinking = widget.message.message.isEmpty && widget.message.state != AiMessageState.end;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: appTheme.fillsPrimary, borderRadius: BorderRadius.circular(16.w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasReasoning) ...[
            _buildThinkingSection(appTheme, isThinking),
            if (widget.message.message.isNotEmpty) SizedBox(height: 12.w),
          ],
          if (widget.message.message.isNotEmpty)
            MarkdownBody(
              data: widget.message.message,
              styleSheet: MarkdownStyleSheet(
                p: TextStyleTheme.regular14.copyWith(color: appTheme.textPrimary, height: 1.6),
                h1: TextStyleTheme.semibold20.copyWith(color: appTheme.textPrimary),
                h2: TextStyleTheme.semibold18.copyWith(color: appTheme.textPrimary),
                h3: TextStyleTheme.semibold16.copyWith(color: appTheme.textPrimary),
                code: TextStyleTheme.regular12.copyWith(
                  color: appTheme.highlightRed,
                  backgroundColor: appTheme.fillsSecondary,
                  fontFamily: 'monospace',
                ),
                codeblockDecoration: BoxDecoration(
                  color: appTheme.fillsSecondary,
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(color: appTheme.separatorsPrimary, width: 1),
                ),
                codeblockPadding: EdgeInsets.all(12.w),
                listBullet: TextStyleTheme.regular14.copyWith(color: appTheme.textSecondary),
                blockquoteDecoration: BoxDecoration(
                  color: appTheme.fillsSecondary,
                  borderRadius: BorderRadius.circular(4.w),
                  border: Border(left: BorderSide(color: appTheme.highlightBlue, width: 4.w)),
                ),
                blockquotePadding: EdgeInsets.all(12.w),
                a: TextStyleTheme.regular14.copyWith(
                  color: appTheme.highlightBlue,
                  decoration: TextDecoration.underline,
                ),
                horizontalRuleDecoration: BoxDecoration(
                  border: Border(top: BorderSide(width: 1.px, color: appTheme.separatorsSecondary)),
                ),
              ),
              builders: {'pre': CodeElementBuilder(isDark: isDark, appTheme: appTheme)},
            ),
        ],
      ),
    );
  }

  Widget _buildThinkingSection(AppThemeExtension appTheme, bool isThinking) {
    return GestureDetector(
      onTap: () => setState(() => _thinkingExpanded = !_thinkingExpanded),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isThinking ? Icons.psychology_outlined : Icons.psychology,
                size: 14.w,
                color: appTheme.textSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                isThinking ? '思考中...' : '已完成思考',
                style: TextStyleTheme.regular12.copyWith(color: appTheme.textSecondary),
              ),
              const Spacer(),
              Icon(
                _thinkingExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 16.w,
                color: appTheme.textSecondary,
              ),
            ],
          ),
          if (_thinkingExpanded) ...[
            SizedBox(height: 8.w),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: _thinkingMaxHeight),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: appTheme.fillsSecondary,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: SingleChildScrollView(
                controller: _thinkingScrollController,
                physics: const ClampingScrollPhysics(),
                child: Text(
                  widget.message.reasoningContent,
                  style: TextStyleTheme.regular12.copyWith(color: appTheme.textSecondary, height: _kThinkingLineHeight),
                ),
              ),
            ),
            SizedBox(height: 4.w),
          ],
        ],
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
