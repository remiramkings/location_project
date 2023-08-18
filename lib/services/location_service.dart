import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_project/models/distance_delegate_model.dart';
import 'package:location_project/models/location_model.dart';
import 'package:location_project/services/shared_preference_service.dart';

class LocationService {

  static final LocationService _instance = LocationService();

  static LocationService getInstance(){
    return _instance;
  }  

  static Future<Position> getCurrentLocation() async {
    LocationPermission permission;
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location serviced are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
  static Future<String?> getAddressFromLocation(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if(placemarks == null  || placemarks.length<1 ){
      return null;
    }
    return '${placemarks.first.locality}';
  }

  double getDistance(LocationModel previous, LocationModel current){
    double distanceInMeters = Geolocator.distanceBetween(
      previous.latitude, previous.longitude, current.latitude, current.longitude );
    return distanceInMeters;
  }

  Future<DistanceDelegateModel> isLocationChangedForDistance(LocationModel currentLocation, {double distanceInMeters = 10}) async{
    // get the previous location from shared preference
    LocationModel? previousLocation = await SharedPreferenceService
      .getInstance()
      .readPreviousLocation();
    
    if(previousLocation == null){
      await SharedPreferenceService
        .getInstance()
        .writeCurrentLocation(currentLocation);
      
      return DistanceDelegateModel(distance: 0.0, canUpload: true);
    }

    // calculate distance
    double distance = getDistance(previousLocation, currentLocation);
    if(distance >= distanceInMeters){
      await SharedPreferenceService
        .getInstance()
        .writeCurrentLocation(currentLocation);
      
      return DistanceDelegateModel(distance: distance, canUpload: true);
    }

    return DistanceDelegateModel(distance: distance, canUpload: false);
  }
}
