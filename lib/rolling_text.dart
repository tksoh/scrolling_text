import 'package:flutter/material.dart';

class RollingText extends StatefulWidget {
  final String text;
  final Duration? speed;
  final Duration? repeatPause;
  final int? repeatCount;
  final int maxLines;
  final TextStyle? style;
  final bool rewindWhenDone;
  final TextDirection? textDirection;

  const RollingText({
    required this.text,
    this.speed,
    this.repeatPause,
    this.repeatCount,
    this.maxLines = 1,
    this.rewindWhenDone = true,
    this.style,
    this.textDirection,
    super.key,
  });

  @override
  State<RollingText> createState() => RollingTextState();
}

class RollingTextState extends State<RollingText> {
  double scrollOffset = 0;
  ScrollController controller = ScrollController();
  late Duration scrollDuration;
  int? repeatCounter;
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
    assert(widget.maxLines > 0);
    textSize ??= getTextSize(style: widget.style);

    return SizedBox(
      height: textSize!.height * widget.maxLines,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          controller: controller,
          child: Text(
            widget.text,
            style: widget.style,
            textDirection: widget.textDirection,
          ),
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
    rewind();
    start();
  }

  void rewind() {
    setState(() {
      controller.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    });
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
      Future.delayed(widget.repeatPause ?? Duration.zero, () {
        final keepScroll = shouldRepeatScroll();
        if (!keepScroll && widget.rewindWhenDone) {
          rewind();
        }

        if (keepScroll) {
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
    if (repeatCounter == null) {
      // continuous scroll
      return true;
    }

    // counting down
    repeatCounter = repeatCounter! - 1;

    if (repeatCounter! <= 0) {
      // countdown complete
      return false;
    }

    return true;
  }

  Size getTextSize({TextStyle? style}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: 'A', style: style),
      maxLines: 1,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
