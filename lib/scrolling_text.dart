import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final double height;
  final Duration? duration;
  final Duration? reboundDelay;
  final int repeatCount;

  const ScrollingText({
    required this.text,
    required this.height,
    this.duration,
    this.reboundDelay,
    this.repeatCount = -1,
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

  @override
  void initState() {
    repeatCounter = widget.repeatCount;
    scrollDuration = widget.duration ?? const Duration(milliseconds: 500);
    setupNextScroll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scroller = SizedBox(
      height: widget.height,
      child: SingleChildScrollView(
        controller: controller,
        child: Text(widget.text),
      ),
    );

    return scroller;
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
}
