import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final Duration? speed;
  final Duration? reboundDelay;
  final int repeatCount;
  final int lines;
  final TextStyle? style;

  const ScrollingText({
    required this.text,
    this.speed,
    this.reboundDelay,
    this.repeatCount = -1,
    this.lines = 1,
    this.style,
    super.key,
  });

  @override
  State<ScrollingText> createState() => ScrollingTextState();
}

class ScrollingTextState extends State<ScrollingText> {
  double scrollOffset = 0;
  ScrollController controller = ScrollController();
  late Duration scrollDuration;
  late int repeatCounter;
  bool scrolling = true;
  Size? textSize;

  @override
  void initState() {
    repeatCounter = widget.repeatCount;
    scrollDuration = widget.speed ?? const Duration(milliseconds: 500);
    setupNextScroll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    textSize ??= getTextSize(widget.text, style: widget.style);

    return SizedBox(
      height: textSize!.height * widget.lines,
      child: SingleChildScrollView(
        controller: controller,
        child: Text(
          widget.text,
          style: widget.style,
        ),
      ),
    );
  }

  void start() {
    resume();
  }

  void pause() {
    scrolling = false;
  }

  void resume() {
    scrolling = true;
    setupNextScroll();
  }

  void stop() {
    pause();
  }

  void restart() {
    if (scrolling) {
      stop();
    }

    repeatCounter = widget.repeatCount;
    start();
  }

  void setupNextScroll() {
    Future.delayed(scrollDuration, () {
      if (scrolling) {
        scrollText();
      }
    });
  }

  void scrollText() {
    final bottom = controller.position.maxScrollExtent;

    if (scrollOffset >= bottom) {
      debugPrint('bottom reached');
      scrollOffset = 0;
      Future.delayed(widget.reboundDelay ?? Duration.zero, () {
        setState(() {
          controller.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 1),
            curve: Curves.linear,
          );
        });
        if (shouldRepeatScroll()) {
          setupNextScroll();
        }
      });
    } else {
      scrollOffset += 10;
      setState(() {
        controller.animateTo(
          scrollOffset,
          duration: scrollDuration,
          curve: Curves.linear,
        );
      });
      setupNextScroll();
    }
  }

  bool shouldRepeatScroll() {
    if (repeatCounter < 0) {
      // continuous scroll
      return true;
    } else if (repeatCounter <= 1) {
      // countdown complete
      return false;
    } else {
      // counting down
      repeatCounter--;
      return true;
    }
  }

  Size getTextSize(String text, {TextStyle? style}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      textDirection: ui.TextDirection.rtl,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
