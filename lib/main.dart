import 'package:flutter/material.dart';
import 'samples/poem_1.dart';
import 'samples/poem_2.dart';
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
    scrollText = addLineNumbers(poemIf);
    super.initState();
  }

  String addLineNumbers(String text) {
    final lines = text.split('\n');
    final numberedLines = [];

    for (int i = 0; i < lines.length; i++) {
      final lineNum = i + 1;
      final line = lines[i];
      numberedLines.add('$lineNum: $line');
    }

    return numberedLines.join('\n');
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scrollText = addLineNumbers(poemIf);
                      rollController.restart();
                    });
                  },
                  child: const Text('Short Text'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scrollText = addLineNumbers(poemContrast);
                      rollController.restart();
                    });
                  },
                  child: const Text('Long Text'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 500,
              child: showWidgetBorder(
                color: Colors.blue,
                child: RollingText(
                  key: scrollTextKey,
                  controller: rollController,
                  text: scrollText,
                  repeatPause: const Duration(seconds: 1),
                  repeatCount: 1,
                  rewindWhenDone: false,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 25),
                ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    rollController.first();
                  },
                  child: const Text(' << '),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    rollController.previous();
                  },
                  child: const Text('  <  '),
                ),
                const SizedBox(width: 20),
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
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    rollController.next();
                  },
                  child: const Text('  >  '),
                ),
                const SizedBox(width: 20),
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
