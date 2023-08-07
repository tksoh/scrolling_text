import 'package:flutter/material.dart';

import 'samples/poem_1.dart';
import 'rolling_text.dart';

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
  final rollController = RollingTextController();
  late String scrollText;

  @override
  void initState() {
    scrollText = addLineNumbers(poemContrast);
    super.initState();
  }

  String addLineNumbers(String text) {
    final lines = text.split('\n');
    String numbered = '';
    for (int i = 0; i < lines.length; i++) {
      final lineNum = i + 1;
      final line = lines[i];
      numbered += '$lineNum: $line\n';
    }

    return numbered;
  }

  void _incrementCounter() {
    rollController.restart();
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
                controller: rollController,
                text: scrollText,
                repeatPause: const Duration(seconds: 1),
                repeatCount: 1,
                rewindWhenDone: false,
                maxLines: 2,
                style: const TextStyle(fontSize: 25),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: rollController.status,
              builder: (context, value, child) {
                return Text(
                  'Rolling: $value (${rollController.isRolling()})',
                  style: TextStyle(
                    fontSize: 25,
                    color: value ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    rollController.first();
                  },
                  child: const Text(' << '),
                ),
                ElevatedButton(
                  onPressed: () {
                    rollController.previous();
                  },
                  child: const Text('  <  '),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (rollController.status.value) {
                      rollController.pause();
                    } else {
                      rollController.resume();
                    }
                  },
                  child: const Text('Stop/Start'),
                ),
                ElevatedButton(
                  onPressed: () {
                    rollController.next();
                  },
                  child: const Text('  >  '),
                ),
                ElevatedButton(
                  onPressed: () {
                    rollController.last();
                  },
                  child: const Text(' >> '),
                ),
              ],
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
