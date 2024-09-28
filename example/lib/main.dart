import 'dart:math';

import 'package:alphabet_index_listview/alphabet_index_listview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> dataList = List.from({
    "Alpha",
    "AlphaGo",
    "Beta",
    "Black",
    "Crease",
    "Claim",
    "Hello",
    "Hallo",
    "Hero",
    "Words",
    "Work",
    "Woman",
    "Foot",
    "Head",
    "Face",
    "Hair",
    "Nose",
    "Mouth",
    "Eye",
    "Arm",
    "Hand",
    "Finger",
    "Leg",
  });

  List<AlphabetIndexGroup<String>>? generatedList;

  List<String> generateRadonString(){
    var words = 'abcdefghijklmnopqrstuvwxyz'.split('');
    var rng =  Random();
    return List<String>.generate(1000, (index) {
      int length = rng.nextInt(10) + 1; // 随机生成单词长度
      return List<String>.generate(length, (index) => words[rng.nextInt(words.length)]).join();
    });
  }

  @override
  void initState() {
    generatedList = AlphabetIndexTool.analyzeData(dataList, (data) => data);

    Future.delayed(const Duration(milliseconds: 500)).then((value) {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            List<String> newDataList = generateRadonString();
            generatedList =
                AlphabetIndexTool.analyzeData(newDataList, (data) => data);
            setState(() {});
          },
          child: Text(widget.title),
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: AlphabetIndexListView(
          //child: AlphabetIndexSliverView(
          // headerView: Container(height: 120, color: Colors.red),
          // footerView: Container(height: 120, color: Colors.red),
          stickHeader: true,
          dataList: generatedList!,
          preferGroupHeight: 30,
          preferChildHeight: 80,
          onGroupSelected: (int index) {
            if (kDebugMode) {
              print("Group$index");
            }
          },
          tipsBarAlign: AlphabetIndexTipsAlign.center,
          sideBarAlign: AlphabetIndexSideAlign.right,
          sideBarBuilder: (tag, flag) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            );
          },
          tipsBuilder: (int index, String tag) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.yellow.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
              ),
              width: 65,
              height: 65,
              alignment: Alignment.center,
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            );
          },
          groupBuilder: (int groupIndex, String tag) {
            return Container(
              color: Colors.grey,
              height: 30,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Text(tag),
            );
          },
          childBuilder: (int groupIndex, int childIndex, String data) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white70,
                border: Border(
                  bottom: BorderSide(color: Colors.black54, width: 0.5),
                ),
              ),
              height: 80,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Text(data),
            );
          },
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        ),
      ),
    );
  }
}
