import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '小强英语'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String article;
  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/article1.txt').then((value) {
      setState(() {
        article = value;
      });
    });
  }

  void onPressed() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Text('hello'),
            padding: EdgeInsets.all(7), //在textField()的所有方向加7单位的边距（空白）
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (article == null) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      content = Column(
        children: <Widget>[
          RaisedButton(
            child: Text('Clicked Me'),
            onPressed: onPressed,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                article,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: content,
      ),
    );
  }
}
