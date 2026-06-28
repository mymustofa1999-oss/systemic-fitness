import 'dart:convert';
import 'dart:io';




import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';



import '../PrefData.dart';
import '../online_models/IntensivelyModel.dart';
import '../online_models/UserDetail.dart';

class ConstantUrl {






  static Future<bool> isLogin()async {
    return await PrefData.getIsSignIn();
  }
  static bool isNotEmpty(String s) {
    return (s.isNotEmpty);
  }




  static Future<UserDetail> getUserDetail() async {
    String s = await PrefData.getUserDetail();
    print("service---1" + s);
    if (s.isNotEmpty) {
      Map<String, dynamic> userMap;
        userMap = jsonDecode(s) as Map<String, dynamic>;


        final UserDetail user = UserDetail.fromJson(userMap);
        print(user);
        print("service---" + user.toString());

        return user;

    } else {
      return new UserDetail();
    }
  }

  static bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(em);
  }

  static bool phoneNumberValidator(String value) {
    Pattern pattern = r'/^\(?(\d{3})\)?[- ]?(\d{3})[- ]?(\d{4})$/';
    RegExp regex = new RegExp(pattern.toString());
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }






 static  Future<String> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor!; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
      // return androidDeviceInfo.androidId!; // unique ID on Android
    }
  }








  static Future<bool> getNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  static showToast(String s, BuildContext context) {



    if (s.isNotEmpty) {

      Fluttertoast.showToast(
          msg: s,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 12
      );

      // Toast.show(s, context,
      //     duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }


  static List<IntensivelyModel> getIntensivelyModel() {
    List<IntensivelyModel> list = [];

    IntensivelyModel model = new IntensivelyModel();
    model.title = "Low";
    model.desc =
    "Low impact strength training refers to exercise that is easy and gentle on your joints and tendons.";
    list.add(model);

    model = new IntensivelyModel();
    model.title = "Moderate";
    model.desc =
    "Many physical activity recommendations report that moderate exercise is important for health and well-being.";
    list.add(model);

    model = new IntensivelyModel();
    model.title = "High";
    model.desc =
    "While it's often referred to as \"runner's high,\"these feelings can also occur with other forms of aerobic.";
    list.add(model);


    return list;
  }

  static List<IntensivelyModel> getTimeInWeekModel() {
    List<IntensivelyModel> list = [];

    IntensivelyModel model = new IntensivelyModel();
    model.title = "2-3 times in week";
    model.desc =
    "Aerobic exercise can help improve your cardiovascular health,tone muscle ,and support...Duration and frequency:2 to 3 times per week.";
    list.add(model);

    model = new IntensivelyModel();
    model.title = "5 days in week";
    model.desc =
    "Training four to five times a week is ideal,but most people find that unachievable due to time constraints,so many says it's best to aim for three.";
    list.add(model);

    model = new IntensivelyModel();
    model.title = "All 7 days";
    model.desc =
    "Certified fitness trainer jeff bell says if you find yourself constantly skipping rest days to fit in workouts seven.";
    list.add(model);

    return list;
  }

}
