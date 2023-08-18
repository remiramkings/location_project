import 'dart:convert';

import 'package:location_project/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  final SHARED_KEY_PREVIOUS_LOCATION = "SHARED_KEY_PREVIOUS_LOCATION";
  static SharedPreferenceService _instance = SharedPreferenceService();
  static SharedPreferenceService getInstance() {
    return _instance;
  }

  storeData(double latitude, double longitude) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
  }

  Future<double?> getLatitude() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? latitude = prefs.getDouble('latitude');
    return latitude;
  }

  Future<double?> getLongiude() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? longitude = prefs.getDouble('longitude');
    return longitude;
  } 
  Future<LocationModel?> readPreviousLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(SHARED_KEY_PREVIOUS_LOCATION);
    if(value == null || value.isEmpty){
      return null;
    }

    return LocationModel.fromMap(
      jsonDecode(value)
    );
  }

  Future<bool> writeCurrentLocation(LocationModel location) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(SHARED_KEY_PREVIOUS_LOCATION, jsonEncode(location.toMap()));
  }

}
