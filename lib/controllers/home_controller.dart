import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../models/home.dart';
import '../models/rss_feed.dart';

class HomeController extends ControllerMVC {
  Home homeModel = Home();
  GlobalKey<RefreshIndicatorState> refreshKey;
  RssFeed feed;
  String title;

  HomeController() {
    refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  Future<RssFeed> loadFeed() async {
    try {
      final client = http.Client();
      final response = await client.get(homeModel.feedURL);
      return RssFeed.parse(response.body);
    } catch (e) {
      print(e);
    }
    return null;
  }

  updateTitle(_title) {
    setState(() {
      title = _title;
    });
  }

  updateFeed(_feed) {
    setState(() {
      feed = _feed;
    });
  }

  load() async {
    updateTitle(homeModel.loadingFeedMsg);
    await loadFeed().then((result) {
      if (null == result || result.toString().isEmpty) {
        updateTitle(homeModel.feedLoadErrorMsg);
        return;
      }
      updateFeed(result);
      updateTitle(feed.title);
    });
  }

  Future<void> openFeed(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
      );
      return;
    }
    updateTitle(homeModel.feedOpenErrorMsg);
  }
}