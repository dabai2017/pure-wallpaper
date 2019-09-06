import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

Future get_title(String url1) async {
  var url = url1;
  String html, title;
  var response = await http.get(url);

  if (response.statusCode == 200) {
    html = response.body.toString();
    title = html
        .substring(html.indexOf("<title>"), html.indexOf("</title>"))
        .toString();
    title = title.substring(7, title.length).trim();
  } else {
    title = "null";
  }
  return title;
}

Future get_html(String url) async {

  String html;
  var response = await http.get(url);

  if (response.statusCode == 200) {
    html = response.body.toString();

  } else {
    html = "null";
  }
  return html;
}
