import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location_project/models/distance_delegate_model.dart';
import 'package:location_project/models/location_model.dart';
import 'package:location_project/services/location_upload_service.dart';
import 'package:location_project/services/notification.dart';
import 'package:location_project/services/shared_preference_service.dart';
import 'package:location_project/user_location.dart';

import 'services/location_service.dart';

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  CustomNotification notification = CustomNotification();
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    notification.showNotificationText('IsTimedOut');
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  notification.showNotificationText('eventReceived');
  Position position = await LocationService.getCurrentLocation();
      String? placeMarks =
          await LocationService.getAddressFromLocation(position);
      print('#######DATA###########${position.latitude} ${position.longitude}');
       notification.showNotificationText('UserLoc:###########');

      LocationModel currentLocation = LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now());

      DistanceDelegateModel distanceDelegate = await LocationService.getInstance()
          .isLocationChangedForDistance(currentLocation, distanceInMeters: 10);
      notification.showNotificationText('$distanceDelegate');
      if (distanceDelegate.canUpload) {
        UserLocation userLocation = UserLocation(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            timeStamp: currentLocation.timestamp,
            place: placeMarks ?? 'Place not available');
        await LocationUploadService.getInstance().upload(userLocation);
        notification.showNotificationText('Com ${userLocation.timeStamp}');
      }
      notification.showNotificationText('Finished');
  BackgroundFetch.finish(taskId);
}

void main() {
  // Enable integration testing with the Flutter Driver extension.
  // See https://flutter.io/testing/ for more info.
  runApp(MyApp());

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _enabled = false;
  int _status = 0;
  final List<DateTime> _events = [];

  Timer? timer;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  DistanceDelegateModel? distanceDelegateModel;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    //trackDistance();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            startOnBoot: true,
            forceAlarmManager: true,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // <-- Event handler
      // This is the fetch-event callback.
      print("[BackgroundFetch] Event received $taskId");
      setState(() {
        _events.insert(0, DateTime.now());
      });
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    print('[BackgroundFetch] configure success: $status');
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> trackDistance() async {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      Position position = await LocationService.getCurrentLocation();
      String? placeMarks =
          await LocationService.getAddressFromLocation(position);
      print('#######DATA###########${position.latitude} ${position.longitude}');

      LocationModel currentLocation = LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now());

      var distanceDelegate = await LocationService.getInstance()
          .isLocationChangedForDistance(currentLocation, distanceInMeters: 10);

      setState(() {
        distanceDelegateModel = distanceDelegate;
      });

      if (distanceDelegateModel!.canUpload) {
        UserLocation userLocation = UserLocation(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            timeStamp: currentLocation.timestamp,
            place: placeMarks ?? 'Place not available');
        await LocationUploadService.getInstance().upload(userLocation);
      }
    });
  }

  void _onClickEnable(enabled) {
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
    setState(() {
      _enabled = enabled;
    });
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('BackgroundFetch Example',
                style: TextStyle(color: Color.fromARGB(255, 21, 21, 21))),
            backgroundColor: Color.fromARGB(255, 165, 214, 255),
            actions: <Widget>[
              Switch(value: _enabled, onChanged: _onClickEnable),
            ]),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Text('Distance: '),
                  Expanded(
                    flex: 1,
                    child: Text(distanceDelegateModel != null
                        ? '${distanceDelegateModel!.distance.toStringAsFixed(3)} meters'
                        : 'Nothing'),
                  )
                ],
              ),
              Row(
                children: [
                  Text('Can upload: (${dateFormat.format(DateTime.now())}) '),
                  Expanded(
                    flex: 1,
                    child: Text(distanceDelegateModel != null
                        ? '${distanceDelegateModel!.canUpload}'
                        : 'Nothing'),
                  )
                ],
              ),
              Flexible(
                child: ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (BuildContext context, int index) {
                      DateTime timestamp = _events[index];
                      return InputDecorator(
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, top: 10.0, bottom: 0.0),
                              labelStyle:
                                  TextStyle(color: Colors.blue, fontSize: 20.0),
                              labelText: "[background fetch event]"),
                          child: Text(timestamp.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16.0)));
                    }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Row(children: <Widget>[
          ElevatedButton(onPressed: _onClickStatus, child: Text('Status')),
          Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text("$_status"))
        ])),
      ),
    );
  }
}
