import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../user_location.dart';
import 'base_service.dart';


class LocationUploadService extends BaseService {
  static LocationUploadService _instance = LocationUploadService();
  static LocationUploadService getInstance() {
    return _instance;
  }

  upload(UserLocation userLocation) async {
    Uri uri = getApiUri('setLocation');
    var headers = {'Content-Type': 'application/json'};
    var request = {
      "latitude": "${userLocation.latitude}",
      "longitude": "${userLocation.longitude}",
      "place": "${userLocation.place}",
      "timeStamp": DateFormat('dd-MM-yy HH:mm:ss').format(userLocation.timeStamp)
    };

    Response response = await client.post(uri, headers: headers, body: jsonEncode(request));
    if (!isSuccess(response)) {
      throw Exception("Can not upload location");
    }
    Map<String, dynamic> responseData = getMap(response);
    if (!responseData.containsKey('success') ||
        !responseData['success'] == true) {
      throw Exception("Can not upload location");
    }
  }
}
