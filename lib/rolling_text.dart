import 'dart:async';

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
  final RollingTextController? controller;

  const RollingText({
    required this.text,
    this.speed,
    this.repeatPause,
    this.repeatCount,
    this.maxLines = 1,
    this.rewindWhenDone = true,
    this.style,
    this.textDirection,
    this.controller,
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
  final rolling = ValueNotifier(true);
  Size? textSize;
  late RollingTextController textController;
  Timer? rollTimer;

  @override
  void initState() {
    repeatCounter = widget.repeatCount;
    scrollDuration = widget.speed ?? const Duration(milliseconds: 500);
    setupNextScroll();
    initController();
    super.initState();
  }

  void initController() {
    if (widget.controller == null) {
      return;
    }

    // connect controller to state methods
    textController = widget.controller!;
    textController.start = start;
    textController.stop = stop;
    textController.pause = pause;
    textController.restart = restart;
    textController.rewind = rewind;
    textController.resume = resume;
    textController.isRolling = isRolling;

    // setup status monitor
    connectNotifiers(rolling, textController.status);
  }

  void connectNotifiers<T>(ValueNotifier<T> src, ValueNotifier<T> dest) {
    dest.value = src.value;
    src.addListener(() {
      dest.value = src.value;
      debugPrint('addListener: dest.value updated to ${dest.value}');
    });
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
    rolling.value = false;
    rollTimer?.cancel();
    rollTimer = null;
  }

  void resume() {
    if (rolling.value) return;

    rolling.value = true;
    setupNextScroll();
  }

  void stop() {
    pause();
  }

  void restart() {
    if (rolling.value) {
      stop();
    }

    repeatCounter = widget.repeatCount;
    rewind();
    start();
  }

  void rewind() {
    setState(() {
      scrollOffset = 0;
      controller.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    });
  }

  bool isRolling() {
    return rolling.value;
  }

  void setupNextScroll() {
    assert(rollTimer == null);

    rollTimer = Timer(scrollDuration, () {
      rollTimer = null;
      if (rolling.value) {
        scrollText();
      }
    });
  }

  void scrollText() {
    final bottom = controller.position.maxScrollExtent;

    if (scrollOffset >= bottom) {
      debugPrint('bottom reached');
      scrollOffset = 0;
      rollTimer = Timer(widget.repeatPause ?? Duration.zero, () {
        rollTimer = null;
        final keepScroll = shouldRepeatScroll();
        if (!keepScroll && widget.rewindWhenDone) {
          rewind();
        }

        if (keepScroll) {
          setupNextScroll();
        } else {
          rolling.value = false;
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

enum RollingStatus {
  rolling,
  stopped,
}

class RollingTextController {
  final status = ValueNotifier(false);
  VoidCallback start = _notImplemented;
  VoidCallback stop = _notImplemented;
  VoidCallback restart = _notImplemented;
  VoidCallback pause = _notImplemented;
  VoidCallback resume = _notImplemented;
  VoidCallback rewind = _notImplemented;
  ValueGetter<bool> isRolling = _notImplemented;

  static Never _notImplemented() {
    throw UnimplementedError();
  }
}
