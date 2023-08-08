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
  final bool showScrollBar;
  final bool showLineNumbers;

  const RollingText({
    required this.text,
    this.speed,
    this.repeatPause,
    this.repeatCount,
    this.maxLines = 1,
    this.rewindWhenDone = true,
    this.showScrollBar = false,
    this.showLineNumbers = false,
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
  late Size textSize;
  late RollingTextController textController;
  Timer? rollTimer;
  final quickly = const Duration(milliseconds: 1);

  int get lineCount => '\n'.allMatches(widget.text).length + 1;
  double get scrollStepSize => textSize.height;
  double get scrollEndPos => controller.position.maxScrollExtent;
  double get currentPos => controller.position.pixels;
  int get currentLine => controller.position.pixels ~/ textSize.height + 1;

  @override
  void initState() {
    repeatCounter = widget.repeatCount;
    scrollDuration = widget.speed ?? const Duration(milliseconds: 1000);
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
    // textController.goto = goto;
    textController.first = firstLine;
    textController.last = lastLine;
    textController.next = nextLine;
    textController.previous = previousLine;
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
    textSize = getTextSize(style: widget.style);

    return SizedBox(
      height: textSize.height * widget.maxLines,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: widget.showScrollBar,
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: buildList(),
        ),
      ),
    );
  }

  Widget buildText() {
    return Text(
      widget.text,
      style: widget.style,
      textDirection: widget.textDirection,
    );
  }

  Widget buildList() {
    final lines = widget.text.split('\n');

    // calculate width of line numbers pane
    final digits = lines.length.toString().split('').length;
    final numberSize = getTextSize(
      text: '0' * (digits + 1),
      style: widget.style,
    );

    // build the lines
    return ListView(
      shrinkWrap: true,
      children: List.generate(
        lines.length,
        (index) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showLineNumbers) ...[
              SizedBox(
                width: numberSize.width,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${index + 1}',
                    style: widget.style?.copyWith(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 10)
            ],
            Expanded(
              child: Text(
                lines[index],
                style: widget.style,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void stopTimer() {
    rollTimer?.cancel();
    rollTimer = null;
  }

  void start() {
    resume();
  }

  void pause() {
    rolling.value = false;
    stopTimer();
    scrollToPos(currentPos); // interrupt ongoing scrolling
  }

  void resume() {
    if (rolling.value) return;

    rolling.value = true;
    scrollText();
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
    scrollOffset = 0;
    returnTOStartPos();
  }

  bool isRolling() {
    return rolling.value;
  }

  void goto(int lineNum) {
    final offset = (lineNum - 1) * textSize.height;
    if (offset < 0 || offset > scrollEndPos) return;

    scrollOffset = offset;
    scrollToPos(scrollOffset);
  }

  void firstLine() {
    goto(1);
  }

  void lastLine() {
    // FIX ME: when any line is wrapped, the line position cannot be
    // be take directly from the text. As temp workaround, we derive
    // the bottom of the text using the scroll data. Be warned that
    // goto() will not function correctly.
    final lines = scrollEndPos ~/ textSize.height + widget.maxLines;
    goto(lines - widget.maxLines + 1);
  }

  void nextLine() {
    goto(currentLine + 1);
  }

  void previousLine() {
    goto(currentLine - 1);
  }

  void setupNextScroll() {
    stopTimer();
    rollTimer = Timer(scrollDuration, () {
      rollTimer = null;
      if (rolling.value) {
        scrollText();
      }
    });
  }

  Future<void> returnTOStartPos() async {
    await controller.animateTo(
      0,
      duration: quickly,
      curve: Curves.linear,
    );
  }

  Future<void> scrollToPos(double pos) async {
    await controller.animateTo(
      pos,
      duration: quickly,
      curve: Curves.linear,
    );
  }

  void scrollText() {
    if (controller.position.pixels >= scrollEndPos) {
      debugPrint('bottom reached');
      // scrollOffset = 0;
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
      scrollOffset = controller.position.pixels + scrollStepSize;
      controller.animateTo(
        scrollOffset,
        duration: scrollDuration,
        curve: Curves.linear,
      );
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

  Size getTextSize({String text = 'A', TextStyle? style}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
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
  ValueGetter<bool> isRolling = _notImplemented;
  VoidCallback start = _notImplemented;
  VoidCallback stop = _notImplemented;
  VoidCallback restart = _notImplemented;
  VoidCallback pause = _notImplemented;
  VoidCallback resume = _notImplemented;
  VoidCallback rewind = _notImplemented;
  VoidCallback forward = _notImplemented;
  VoidCallback backward = _notImplemented;
  VoidCallback first = _notImplemented;
  VoidCallback last = _notImplemented;
  VoidCallback previous = _notImplemented;
  VoidCallback next = _notImplemented;

  void Function(int) goto = (_) => throw UnimplementedError();

  static Never _notImplemented() {
    throw UnimplementedError();
  }
}
