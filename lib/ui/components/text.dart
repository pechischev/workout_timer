import 'package:flutter/material.dart';

enum TextSize {
  s12,
  s14,
  s16,
  s18,
  s20,
  s24,
  s40,
}

enum TextWeight {
  regular,
  semibold,
}

class TextWidget extends StatelessWidget {
  const TextWidget(
    this.text, {
    Key? key,
    this.color,
    this.lineHeight,
    this.textAlign,
    weight,
    size,
    ellipsis,
    this.maxLines,
  })  : weight = weight ?? TextWeight.regular,
        size = size ?? TextSize.s16,
        ellipsis = ellipsis ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      softWrap: !ellipsis,
      overflow: ellipsis ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontWeight: weight.value,
        fontSize: size.value,
        color: color ?? Colors.black,
      ),
      textAlign: textAlign,
      strutStyle: StrutStyle(fontSize: size.value, height: lineHeight),
    );
  }

  final String text;
  final TextWeight weight;
  final TextSize size;
  final Color? color;
  final double? lineHeight;
  final bool ellipsis;
  final int? maxLines;
  final TextAlign? textAlign;
}

extension TextSizeExt on TextSize {
  double get value {
    final sizes = {
      TextSize.s12: 12.0,
      TextSize.s14: 14.0,
      TextSize.s18: 18.0,
      TextSize.s20: 20.0,
      TextSize.s24: 24.0,
      TextSize.s40: 40.0,
    };

    return sizes[this] ?? 16.0;
  }
}

extension TextWeightExt on TextWeight {
  FontWeight get value {
    return this == TextWeight.semibold ? FontWeight.w600 : FontWeight.w400;
  }
}
