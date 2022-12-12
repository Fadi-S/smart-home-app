import 'package:http/http.dart' as http;

class Request {

  static String domain = "192.168.94.153";

  static Future<http.Response> get(String path, [Map<String, dynamic>? params]) async {
    return await http.get(Uri.http(domain, path, params));
  }

}