import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:rich_text_flutter/model.dart';

import 'article_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sharp English',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '小强学英语'),
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
  final ScrollController _scrollController = new ScrollController();
  List<Article> articles;

  void init() async {
    String jsonStr = await rootBundle.loadString('assets/articles.json');
    Map<String, dynamic> map = json.decode(jsonStr);
    List list = map['articles'];
    List<Article> articles = [];
    list.forEach((m) {
      Article article = Article.fromMap(m);
      articles.add(article);
    });
    setState(() {
      this.articles = articles;
    });
  }

  void onTapArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArticlePage(article)),
    );
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (articles == null) {
      body = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      body = Padding(
          padding: const EdgeInsets.all(8.0),
          child: StaggeredGridView.countBuilder(
            controller: _scrollController,
            itemCount: articles.length,
            crossAxisCount: 4,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            staggeredTileBuilder: (index) => StaggeredTile.fit(2),
            itemBuilder: (context, index) {
              Article article = articles[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => this.onTapArticle(article),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Image(image: AssetImage(article.coverUrl)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        article.titleString,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: body,
    );
  }
}
