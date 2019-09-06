import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper/utils/Toast.dart';
import 'package:wallpaper/utils/datas.dart';

var mode = 1;

main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyApp();
  }
}

class _MyApp extends State {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


  }

  final _bottomNavigationColor = Colors.blue;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "轻壁纸客户端",
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() async {
              _currentIndex = index;

              if (_currentIndex == 0) {
                mode = 1;

                title = "电脑";
              } else {
                mode = 2;
                title = "手机";
              }

              viewlist = await new List<Widget>();
              await getData();
              setState(() {
                data.forEach((v) {
                  String imgurl = v.toString();

                  viewlist.add(GestureDetector(
                    child: CachedNetworkImage(
                      imageUrl: imgurl,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Icon(Icons.refresh),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ));
                });
              });
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.computer,
                  color: _bottomNavigationColor,
                ),
                title: Text(
                  '电脑壁纸',
                  style: TextStyle(color: _bottomNavigationColor),
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.phone_android,
                  color: _bottomNavigationColor,
                ),
                title: Text(
                  '手机壁纸',
                  style: TextStyle(color: _bottomNavigationColor),
                )),
          ],
        ),
        appBar: AppBar(

          centerTitle: true,
          title: Text("轻壁纸 - $title每日壁纸"),
        ),
        body: Home(),
      ),
    );
  }
}

var title = "";

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Home();
  }
}

List<Widget> viewlist = new List<Widget>();

class _Home extends State {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: <Widget>[

        Center(
          child: Text("请选择壁纸类型",
          style: TextStyle(
            fontSize: 22
          ),),
        ),

        RefreshIndicator(
          onRefresh: _onRefresh,
          child: GridView.count(
            crossAxisCount: 1,
            children: viewlist,
            controller: scrollController,
          ),
        ),
      ],
    );
  }

  /**
   * 下拉刷新方法,为list重新赋值
   */
  Future<Null> _onRefresh() async {
    //获取数据

    var permission =
    await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);

    await PermissionHandler().requestPermissions(<PermissionGroup>[
        PermissionGroup.storage, // 在这里添加需要的权限
      ]);


    viewlist = await new List<Widget>();

    setState(() {
      getData();

      data.forEach((v) {
        String imgurl = v.toString();

        viewlist.add(GestureDetector(
          child: CachedNetworkImage(
            imageUrl: imgurl,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => Icon(Icons.refresh),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          onTap: () {
            imgurlto = imgurl;

            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SecondScreen()));
          },
          onLongPress: () {
            imgurlto = imgurl;
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text('下载图片'),
                      content: Text(("图片来源：$imgurl，是否下载？")),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text("取消"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(child: new Text("确定"), onPressed: _save),
                      ],
                    ));
          },
        ));
      });
    });
  }

  _save() async {
    Navigator.of(context).pop();
    Toast.toast(context,
        msg: "开始下载", position: ToastPostion.bottom, showTime: 2000);
    var response = await Dio()
        .get(imgurlto, options: Options(responseType: ResponseType.bytes));
    final result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
    if (await result) {
      setState(() {
        Toast.toast(context,
            msg: "下载完成", position: ToastPostion.bottom, showTime: 4000);
      });
    } else {
      setState(() {
        Toast.toast(context,
            msg: "下载失败", position: ToastPostion.bottom, showTime: 4000);
      });
    }
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('查看大图'),
        ),
        body: Column(
          children: <Widget>[
            Image.network(imgurlto),
            RaisedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Toast.toast(context,
                    msg: "开始下载", position: ToastPostion.bottom, showTime: 2000);
                var response = await Dio().get(imgurlto,
                    options: Options(responseType: ResponseType.bytes));
                final result = await ImageGallerySaver.saveImage(
                    Uint8List.fromList(response.data));

              },
              child: Text(
                "下载",
                style: TextStyle(),
              ),
            )
          ],
        ));
  }
}

String imgurlto = "";
