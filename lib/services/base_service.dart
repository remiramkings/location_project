import 'dart:convert';

import 'package:http/http.dart';

class BaseService {

  Client get client {
    return Client();
  }
  
  Map<String, dynamic> getMap(Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  bool isSuccess(Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Uri getApiUri(String endpoint, {Map<String, dynamic>? queryParams}) {
    return Uri.https("0111e260-49a6-49e2-98a0-451d6c4d03b4.mock.pstmn.io","/$endpoint", queryParams);
  }

}