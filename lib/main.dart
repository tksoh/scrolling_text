import 'package:flutter/material.dart';

import 'rolling_text.dart';

const longText = '''
/// A widget that does not require mutable state.
///
/// A stateless widget is a widget that describes part of the user interface by
/// building a constellation of other widgets that describe the user interface
/// more concretely. The building process continues recursively until the
/// description of the user interface is fully concrete (e.g., consists
/// entirely of [RenderObjectWidget]s, which describe concrete [RenderObject]s).
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=wE7khGHVkYY}
''';

const arabicText = '''
دی ناگه از نگارم اندر رسید نامه
قالت: رای فوادی من هجرک القیامه
گفتم که: عشق و دل را باشد علامتی هم
قالت: دموع عینی لم تکف بالعلامه
گفتا که: می چه سازی گفتم که مر سفر را
قالت: فمر صحیحا بالخیر و السلامه
گفتم: وفا نداری گفتا که: آزمودی
من جرب المجرب حلت به الندامه
گفتم: وداع نایی واندر برم نگیری
قالت: ترید وصلی سرا و لا کرامه
گفتا: بگیر زلفم گفتم: ملامت آید
قالت: الست تدری العشق و الملامه
''';

final scrollTextKey = GlobalKey<RollingTextState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    scrollTextKey.currentState?.restart();
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            showWidgetBorder(
              color: Colors.blue,
              child: RollingText(
                key: scrollTextKey,
                text: longText,
                reboundDelay: const Duration(seconds: 2),
                repeatCount: 1,
                rewindOnComplete: false,
                lines: 2,
                style: const TextStyle(fontSize: 25),
                child: const SelectableText(
                  arabicText,
                  style: TextStyle(fontSize: 14),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Widget showWidgetBorder({
  required Widget child,
  Color color = Colors.grey,
  bool enabled = true,
  double width = 1,
}) {
  return enabled
      ? Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: width,
            ),
          ),
          child: child,
        )
      : child;
}
