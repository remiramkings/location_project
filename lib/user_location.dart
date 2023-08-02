import 'dart:convert';

class UserLocation {
  double latitude;
  double longitude;
  DateTime timeStamp;
  String place;
  UserLocation({required this.latitude, required this.longitude, required this.timeStamp, required this.place});

  static Map<String, dynamic> toMap(UserLocation userLocation) =>
      {
        'latitude': userLocation.latitude,
        'longitude': userLocation.longitude,
        'timeStamp' : userLocation.timeStamp.millisecondsSinceEpoch,
        'place' : userLocation.place};

  static UserLocation fromMap(Map<String, dynamic> userLocationMap){
    return UserLocation(
     latitude: userLocationMap['latitude'], 
     longitude: userLocationMap['longitude'], 
     timeStamp: DateTime.fromMillisecondsSinceEpoch(userLocationMap['timeStamp']),
     place: userLocationMap['place'] 
    );
  }                                                                                                  
}
