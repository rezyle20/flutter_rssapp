import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reorderables/reorderables.dart';

import '../controllers/home_controller.dart';

class RSSHome extends StatefulWidget {
  RSSHome() : super();

  @override
  _RSSHomeState createState() => _RSSHomeState();
}

class _RSSHomeState extends StateMVC<RSSHome> {
  HomeController _con;
  List<Widget> feedRows;

  _RSSHomeState() : super(HomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.updateTitle(_con.homeModel.title);
    _con.load();
  }

  title(title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  subtitle(subTitle) {
    return Text(
      subTitle,
      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w100),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  thumbnail(imageUrl) {
    return Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: CachedNetworkImage(
        placeholder: (context, url) => Icon(Icons.image),
        imageUrl: imageUrl,
        height: 50,
        width: 70,
        alignment: Alignment.center,
        fit: BoxFit.fill,
      ),
    );
  }

  isFeedEmpty() {
    return null == _con.feed || null == _con.feed.items;
  }

  featureTitle(title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  featureDesc(desc) {
    return Text(
      desc,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  featuredThumbnail(imageUrl) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: CachedNetworkImage(
        placeholder: (context, url) => Icon(Icons.image),
        imageUrl: imageUrl,
        height: 200,
        alignment: Alignment.center,
        fit: BoxFit.fill,
      ),
    );
  }

  featuredFeed() {
    final item = _con.feed.items[0];
    return FlexibleSpaceBar(
      background: Card(
        elevation: 2,
        child: ListTile(
            title: Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Column(
                children: [
                  featuredThumbnail(item.enclosure.url),
                  featureTitle(item.title),
                  featureDesc(item.description),
                ],
              ),
            ),
            onTap: () => _con.openFeed(item.link)
        ),
      ),
    );
  }

  buildFeedRows() {
    feedRows = List<Widget>.generate(_con.homeModel.feedLimit, (index) {
      return Card(
        key: UniqueKey(),
        elevation: 2,
        child: ListTile(
          title: title(_con.feed.items[index].title),
          subtitle: subtitle(_con.feed.items[index].pubDate),
          leading: thumbnail(_con.feed.items[index].enclosure.url),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.grey,
            size: 30.0,
          ),
          contentPadding: EdgeInsets.all(5.0),
          onTap: () => _con.openFeed(_con.feed.items[index].link),
        ),
      );
    });
  }

  body(BuildContext context) {
    if (!isFeedEmpty()) {
      buildFeedRows();
    }

    return isFeedEmpty()
        ? Center(
            child: CircularProgressIndicator(),
          )
        : CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              snap: true,
              floating: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              expandedHeight: 400,
              flexibleSpace: featuredFeed(),
            ),
            ReorderableSliverList(
              delegate: ReorderableSliverChildListDelegate(feedRows),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _con.feed.items.removeAt(oldIndex);
                  _con.feed.items.insert(newIndex, item);
                });
              },
            ),
          ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_con.title),
      ),
      body: body(context),
    );
  }
}
