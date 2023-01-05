import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:panorama/panorama.dart';
import 'package:http/http.dart' as http;

/// A widget that displays a panoramic image at the specified coordinates,
/// with optional markers and interactive features.
class Viewer extends StatefulWidget {
  const Viewer(
      {Key? key,
      required this.coordinate,
      this.height,
      this.width,
      this.loadingWidget,
      this.closeWidget,
      this.pinX,
      this.pinY,
      this.animation,
      this.maxZoom,
      this.minZoom,
      this.animSpeed,
      this.sensitivity,
      this.pinIcon,
      this.onSaved,
      this.showClose,
      required this.controller})
      : super(key: key);

  /// The coordinates of the location to display in the panoramic image.
  final LatLng coordinate;

  /// The X position of the marker, as a fraction of the width of the image.
  final double? pinX;

  /// The Y position of the marker, as a fraction of the height of the image.
  final double? pinY;

  /// The height of the panoramic image.
  final double? height;

  /// The width of the panoramic image.
  final double? width;

  /// The widget to display while the panoramic image is loading.
  final Widget? loadingWidget;

  /// The widget to display as a close button.
  final Widget? closeWidget;

  /// Whether to show the close button.
  final bool? showClose;

  /// Whether to animate the panoramic image when it is loaded.
  final bool? animation;

  /// The maximum zoom level allowed for the panoramic image.
  final double? maxZoom;

  /// The minimum zoom level allowed for the panoramic image.
  final double? minZoom;

  /// The speed of the animation when the panoramic image is loaded.
  final double? animSpeed;

  /// The sensitivity of the pan and zoom controls.
  final double? sensitivity;

  /// The icon to use for the marker.
  final IconData? pinIcon;

  /// A callback function that is called when the marker is placed.
  ///
  /// The `x` and `y` parameters represent the marker's position as fractions of the width and height of the image, respectively.
  final Function(double x, double y)? onSaved;

  /// The controller for the panoramic image.
  final Galli360 controller;

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  double speed = 2;
  bool imageLoaded = false;
  String? imageLink;
  bool error = false;
  double? markerX;
  double? markerY;

  /// Retrieves the panoramic image from the server.
  get360Image() async {
    final response = await http.get(
      Uri.parse(
          "https://gallimaps.com/getstreetview/${widget.coordinate.latitude},${widget.coordinate.longitude}"),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        imageLink = jsonDecode(response.body)["data"]["imgurl"];
      });
    } else {
      setState(() {
        error = true;
      });
    }
  }

  @override
  void initState() {
    get360Image();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller._initialised) {
      return imageLink == null
          ? WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Center(
                child: widget.loadingWidget ??
                    const CircularProgressIndicator(
                      color: Colors.blue,
                    ),
              ),
            )
          : WillPopScope(
              onWillPop: () async {
                if (markerX == null && markerY == null) {
                  return true;
                } else {
                  setState(() {
                    markerX = null;
                    markerY = null;
                  });
                  return false;
                }
              },
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                      width: widget.width ??
                          MediaQuery.of(context).size.width * 0.9,
                      height: widget.height ??
                          MediaQuery.of(context).size.height * 0.8,
                      child: Stack(children: [
                        Listener(
                          onPointerDown: (_) {
                            setState(() {
                              speed = 0;
                            });
                          },
                          child: Panorama(
                              longitude: widget.pinY == null
                                  ? 0
                                  : (widget.pinY! / 10000) * pi,
                              latitude: widget.pinX == null
                                  ? 0
                                  : (widget.pinX! / 10000) * pi,
                              maxZoom: widget.maxZoom ?? 5.0,
                              minZoom: widget.minZoom ?? 1.0,
                              onTap: (lng, lat, tilt) {
                                if (widget.pinX == null &&
                                    widget.pinY == null) {
                                  setState(() {
                                    markerX = lat;
                                    markerY = lng;
                                  });
                                }
                              },
                              hotspots: [
                                Hotspot(
                                  latitude: -90.0,
                                  longitude: 90.0,
                                  width: 200.0,
                                  height: 200.0,
                                  // widget: Image.asset('images_v2/app_icon_v2.png'),
                                  widget: SvgPicture.network(
                                      "http://uat.gotaxinepal.com/storage/galliIcon.svg"),
                                ),
                                widget.pinX != null && widget.pinY != null
                                    ? Hotspot(
                                        latitude: widget.pinX!,
                                        longitude: widget.pinY!,
                                        width: 150.0,
                                        height: 128.0,
                                        widget: Column(
                                          children: [
                                            Icon(
                                              widget.pinIcon ??
                                                  Icons.location_on,
                                              size: 64,
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(
                                              height: 64,
                                            )
                                          ],
                                        ),
                                      )
                                    : Hotspot(),
                                widget.onSaved == null ||
                                        (markerX != null && markerY != null)
                                    ? Hotspot(
                                        latitude: markerX!,
                                        longitude: markerY!,
                                        width: 150.0,
                                        height: 128.0,
                                        widget: Column(
                                          children: [
                                            Icon(
                                              widget.pinIcon ??
                                                  Icons.location_on,
                                              size: 64,
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(
                                              height: 64,
                                            )
                                          ],
                                        ),
                                      )
                                    : Hotspot()
                              ],
                              animSpeed: (widget.animation != null &&
                                      !widget.animation!)
                                  ? 0
                                  : widget.animSpeed ?? speed,
                              sensitivity: widget.sensitivity ?? 2,
                              child: Image.network(imageLink!)),
                        ),
                        widget.showClose == null || widget.showClose!
                            ? Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: widget.closeWidget ??
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                          child: const Center(
                                              child: Icon(Icons.close_rounded)),
                                        )))
                            : const SizedBox(),
                        widget.onSaved == null ||
                                markerX == null ||
                                markerY == null
                            ? const SizedBox()
                            : Positioned(
                                bottom: 16,
                                left: (((widget.width ??
                                            MediaQuery.of(context).size.width *
                                                0.9) -
                                        MediaQuery.of(context).size.width *
                                            0.2) /
                                    2),
                                child: GestureDetector(
                                  onTap: () {
                                    widget.onSaved!(markerX!, markerY!);
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      height: 36,
                                      child: const Center(
                                        child: Text("Save"),
                                      ),
                                    ),
                                  ),
                                ))
                      ])),
                ),
              ),
            );
    } else {
      return const Center(
        child: Card(
          child: SizedBox(
            width: 300,
            height: 300,
            child: Center(child: Text("Initialise App with key before use")),
          ),
        ),
      );
    }
  }
}

/// Represents a geographic coordinate.
class LatLng {
  /// The latitude of the coordinate.
  final double latitude;

  /// The longitude of the coordinate.
  final double longitude;
  LatLng({required this.latitude, required this.longitude});
}

/// A controller that manages the panoramic image viewer.
class Galli360 {
  final String authkey;
  Galli360(this.authkey) {
    _getDeviceKey();
  }
  verify(token, key) async {
    final response = await http.post(
        Uri.parse("http://map.gallimap.com/authTest/api/verify"),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"auth_token": token, "device_key": key}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)["status"] == true) {
        _initialised = true;
      } else {
        _initialised = false;
      }
    } else {
      _initialised = false;
    }
  }

  _getDeviceKey() async {
    String? key;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      key = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      key = androidDeviceInfo.id; // unique ID on Android
    }
    if (key != null) {
      verify(authkey, key);
    }
  }

  bool _initialised = false;
}
