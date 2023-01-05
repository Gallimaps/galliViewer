[![Galli Maps](https://github.com/Gallimaps/galliViewer/blob/main/assets/galliIcon.svg)](https://gallimaps.com/)
# Galli360 Viewer
[![pub package](https://img.shields.io/pub/v/galli360viewer.svg)](https://pub.dartlang.org/packages/galli360viewer)


Galli Maps' flutter library to show 360 images of streets of Nepal
1. wide, imersive view
2. pan, tilt and zoom in different parts of images
3. single tap to pin a building/location
4. save the pinned location and share it with others


## Setup

Add galli360viewer as a dependency in your pubspec.yaml file
```yaml
dependencies:
    galli360viewer: ${last_version}
```

## How to use

Import and add the Galli360Viewer widget to your project
```dart
import 'package:galli360viewer/galli360viewer.dart';
... ...

final Galli360 controller = Galli360(token);

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Viewer(
        coordinate: LatLng(37.421997, -122.084057),
        pinX: 0.5,
        pinY: 0.5,
        height: 400,
        width: 400,
        loadingWidget: Container(
          child: Center(
            child: const CircularProgressIndicator(),
          ),
        ),
        closeWidget: Container(
          child: Center(
            child: Text('Close'),
          ),
        ),
        showClose: true,
        animation: true,
        maxZoom: 2,
        minZoom: 0.5,
        animSpeed: 5,
        sensitivity: 5,
        pinIcon: Icons.location_on,
        onSaved: (double x, double y) {
          print(x);
          print(y);
        },
        controller: controller,
      ),
    );
  }
 ```

## Preview
![Preview](https://github.com/Gallimaps/galliViewer/blob/main/assets/demo.gif)