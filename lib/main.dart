import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

/// 動的にプレースホルダーとウィジェットを置き換えるテキストウィジェット
class DynamicTextWidget extends StatelessWidget {
  /// テンプレートテキスト。プレースホルダーは `{}` で囲む
  final String template;

  /// プレースホルダーと対応するウィジェットのマップ
  final Map<String, Widget> replacements;

  /// テキストスタイル
  final TextStyle textStyle;

  const DynamicTextWidget({
    super.key,
    required this.template,
    required this.replacements,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // 出力するスパンリストを初期化
    final List<InlineSpan> spans = [];

    // テンプレート内のプレースホルダーを正規表現で検索
    final RegExp regex = RegExp(r'\{(.*?)\}');
    final Iterable<RegExpMatch> matches = regex.allMatches(template);

    int currentIndex = 0;

    for (final match in matches) {
      // プレースホルダー前の通常の文字列を取得
      final start = match.start;
      if (currentIndex < start) {
        spans.add(TextSpan(
          text: template.substring(currentIndex, start),
          style: textStyle,
        ));
      }

      // プレースホルダーの中身を取得。null の場合にデフォルト値を設定
      final placeholder = match.group(1) ?? 'unknown_placeholder';

      // プレースホルダーに対応するウィジェットを生成し追加
      spans.add(_buildInlineSpan(
        placeholder: placeholder,
        widget: replacements[placeholder],
        textStyle: textStyle,
      ));

      currentIndex = match.end; // 現在位置を更新
    }

    // 最後に残った文字列を追加
    if (currentIndex < template.length) {
      spans.add(TextSpan(
        text: template.substring(currentIndex),
        style: textStyle,
      ));
    }

    // RichText で InlineSpan をまとめて表示
    return RichText(
      text: TextSpan(
        children: spans,
        style: textStyle,
      ),
    );
  }

  /// プレースホルダーをウィジェットに変換し、適切な InlineSpan を返す
  ///
  /// - [placeholder]: プレースホルダー文字列
  /// - [widget]: 対応するウィジェット（`null`の場合もあり）
  /// - [textStyle]: デフォルトのテキストスタイル
  ///
  /// Returns: InlineSpan (TextSpan または WidgetSpan)
  InlineSpan _buildInlineSpan({
    required String placeholder,
    Widget? widget,
    required TextStyle textStyle,
  }) {
    // テキストウィジェットの場合、TextSpanを生成
    if (widget is Text) {
      return TextSpan(
        text: widget.data,
        style: widget.style ?? textStyle,
      );
    }

    // 通常のウィジェットの場合、WidgetSpanを生成
    else if (widget != null) {
      final resolvedFontSize = _resolveFontSize(textStyle);
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: SizedBox(
          width: resolvedFontSize,
          height: resolvedFontSize,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: widget,
          ),
        ),
      );
    }

    // 未定義のプレースホルダーの場合、赤字の TextSpan を生成
    return TextSpan(
      text: '{$placeholder}',
      style: textStyle.copyWith(color: Colors.red),
    );
  }

  /// TextStyle からフォントサイズを解決し、デフォルト値を返す
  ///
  /// - [textStyle]: フォントサイズを含むテキストスタイル
  ///
  /// Returns: フォントサイズ (`null` の場合はデフォルト値 16.0)
  double _resolveFontSize(TextStyle textStyle) {
    return textStyle.fontSize ?? 16.0; // フォントサイズが指定されていない場合は 16.0 を使用
  }
}

// 使用例
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.black); // fontSize未指定のスタイル
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Dynamic Text Widget Example"),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DynamicTextWidget(
                textStyle: textStyle,
                template: "一時停止{placeholder1}を見たら{placeholder2}車は止まらなければならない",
                replacements: {
                  "placeholder1": Icon(Icons.block, color: Colors.red),
                  "placeholder2": Icon(Icons.directions_car, color: Colors.blue),
                },
              ),
              SizedBox(height: 20),
              DynamicTextWidget(
                textStyle: textStyle,
                template:
                    "{placeholder1}信号が赤になっていることを確認したら{placeholder2}歩行者は止まらなければならない",
                replacements: {
                  "placeholder1": Icon(Icons.traffic, color: Colors.green),
                  "placeholder2": Icon(Icons.directions_walk, color: Colors.orange),
                },
              ),
              SizedBox(height: 20),
              DynamicTextWidget(
                textStyle: textStyle,
                template:
                    "{placeholder1}信号機{placeholder2}歩行者{placeholder3}一時停止{placeholder4}危ない",
                replacements: {
                  "placeholder1": Icon(Icons.traffic, color: Colors.green),
                  "placeholder2": Icon(Icons.directions_walk, color: Colors.orange),
                  "placeholder3": Icon(Icons.traffic, color: Colors.blue),
                  "placeholder4": Text(
                    '止まれ',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
