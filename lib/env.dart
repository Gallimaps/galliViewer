class GalliViewerUrl {
  String getImage(lat, lng) => "https://gallimaps.com/getstreetview/$lat,$lng";
  String verify = "https://earth.gallimap.com/authTest/api/verify";
}

final GalliViewerUrl galliViewerUrl = GalliViewerUrl();
