import 'package:intl/intl.dart';

class LocationModel {
  double latitude;
  double longitude;
  DateTime timestamp;

  static final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map){
    return LocationModel(
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: dateFormat.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap(){
    return ({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': dateFormat.format(timestamp)
    });
  }
}