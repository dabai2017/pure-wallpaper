import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wallpaper/main.dart';

String imgurltotal = "";

List data = new List();

/**
 * 初始化list数据
 */

int num = 500;

Future getData() async {
  if (mode == 1) {
    List datalist = new List();

    imgurltotal =
        "http://wallpaper.apc.360.cn/index.php?c=WallPaper&a=getAppsByOrder&order=create_time&start=0&count=$num&from=360chrome";

    var response = await http.get(imgurltotal);
    if (response.statusCode == 200) {
      String html = response.body.toString();

      var parsedJson = json.decode(response.body.toString());

      datalist = parsedJson["data"];

      data.clear();
      datalist.forEach((v) {
        data.add(v["url"]);
      });
    }
  } else {
    List datalist = new List();

    imgurltotal =
        "http://service.picasso.adesk.com/v1/vertical/vertical?limit=$num&skip=180&adult=false&first=0&order=hot";

    var response = await http.get(imgurltotal);
    if (response.statusCode == 200) {
      String html = response.body.toString();

      var parsedJson = json.decode(response.body.toString());

      datalist = parsedJson["res"]["vertical"];

      data.clear();
      datalist.forEach((v) {
        data.add(v["img"]);
      });
    }
  }
}
