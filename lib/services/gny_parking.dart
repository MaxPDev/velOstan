import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';

import 'dart:convert'; // to user jsonDecode
import 'dart:developer';

import 'package:nancy_stationnement/models/parking.dart';
import 'package:nancy_stationnement/database/database_handler.dart';
import 'package:nancy_stationnement/services/check_connection.dart';
import 'package:nancy_stationnement/config/services_config.dart' as config;

class GnyParking extends ChangeNotifier {

  /// Vrai ou faux si la connection au service est possible ou non.
  bool isGnyConnection = false;

  /// Vrai ou faux si la base de donnée local est vide ou non
  bool isParkingDatabaseEmpty = true;

  /// liste des objets parkings
  static List<Parking> _parkings = [];

  /// Parking selectionné sur la map
  Parking? selectedParking;

  /// Liste des marqueurs de parkings
  static List<Marker> _markers = [];

  GnyParking() {
    if (kDebugMode) {
      print("GnyParking constructor");
    }
  }

  /// Prépare la liste de parking, génère les marqueur
  Future<void> initParkingAndGenerateMarkers() async {
    // Delete database : only for dev test, or implement if fulling database doesn't work
    // await DatabaseHandler.instance.deleteDatabase("parkings.db");

    // Initialise les Parking
    await initParking();
    // Génère les marqueurs
    generateParkingMarkers();
  }

  /// Supprime la DB pour la remplir à nouveauPrépare la liste de parking, génère les marqueur
  Future<void> reInitParkingAndGenerateMarkers() async {

    // Supprime la database : pour tester le remplissage.
      // await DatabaseHandler.instance.deleteDatabase('parkings.db');

    // Vérifie la connection internet vers go.gny.org
    isGnyConnection = await CheckConnection.isGnyConnection();
    
    if(isGnyConnection) {await DatabaseHandler.instance.resetParkingsTables();}
    // Initialise les Parking
    await initParking();
    // Génère les marqueurs
    generateParkingMarkers();
  }

  /// Rempli la liste de Parking depuis la DB Local:
  ///  Si pas de parking dans la DB Local :
  ///   Récupère les informations depuis g-ny.org et rempli la DB
  Future<void> initParking() async {
    // Vérifie la connection internet vers go.gny.org
    isGnyConnection = await CheckConnection.isGnyConnection();

    // Vérifie dans la base de données si la table des parking est vide (true) ou remplie (false)
    isParkingDatabaseEmpty = await DatabaseHandler.instance.isParkingEmpty();

    // Rempli la base de données si elle est vide, en allant chercher les données
    if (isParkingDatabaseEmpty) {
      if (isGnyConnection) {
        if (kDebugMode) {
          print("fulling parking database");
        }

        Map<String, dynamic> data = await fetchDataParkings();

        data.forEach((key, value) async {
          await DatabaseHandler.instance
              .createParking(Parking.fromAPIJson(data[key]));
        });
      } else {
        if (kDebugMode) {
          print(
            "Récupération des Parkings impossible, pas de connection");
        } 
      }
    } else {
      if (kDebugMode) {
        print("database parking already setup");
      }
    }
    // _parkings.clear();
    _parkings = await DatabaseHandler.instance.getAllParking();
    await fetchDynamicDataParkings();

    inspect(_parkings);
  }

  // Récupère les données de parking depuis go.g-ny.org
  Future<Map<String, dynamic>> fetchDataParkings() async {
    try {
      // Récupère les données via l'API
      var uri = Uri.parse('${config.gnyUri}${config.gnyJson}');
      Response response = await get(uri);
      Map<String, dynamic> data = jsonDecode(response.body);

      return data;
    } catch (e) {
      //todo : remonter les erreurs dans un affichage user
      if (kDebugMode) {
        print('Caught error in GnyParking.fetchDataParking() : $e');
      }
      rethrow;
    }
  }

  // Récupère les données dynamiques de parking depuis go.g-ny.org
  Future<void> fetchDynamicDataParkings() async {
    // Vérifie la connection internet vers go.gny.org
    isGnyConnection = await CheckConnection.isGnyConnection();
    if(isGnyConnection) {
      try {
        // Récupère les données via l'API
        var uri = Uri.parse('${config.gnyUri}${config.gnyHot}');
        Response response = await get(uri);
        Map<String, dynamic> data = jsonDecode(response.body);

        // Met à jour les objets parkings avec les nouvelles données
        for (Parking parking in _parkings) {
          data.forEach((key, value) {
            if (parking.id == key) {
              parking.capacity = data[key]["capacity"].toString();
              parking.available = data[key]["mgn:available"].toString();
              parking.isClosed = data[key]["mgn:closed"];
              parking.colorHexa = data[key]["ui:color"];
              parking.colorText = data[key]["ui:color_en"];
            }
          });
        }

        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print('Caught error in GnyParking.fetchDynamicDataParking() : $e');
          // snackBarError = errorToSnack(e.toString());
        }
      }
    }
  }

  // Construit les markers depuis les objets parking
  void generateParkingMarkers() {
    List<Marker> markers = [];
    for (var parking in _parkings) {
      //todo récupérer depuis db
      markers.add(Marker(
          key: const ObjectKey("parking_marker"),
          // objectId: parking.id,
          point: LatLng(parking.coordinates[1],
              parking.coordinates[0]), //? refaire en parking.lat et.long ?
          width: 30,
          height: 30,
          builder: (context) => GestureDetector(
            // onTap: () => //,
            onTap: () {
              if (kDebugMode) {
                print("${parking.name} tapped");
              }
              selectedParking = parking;
              inspect(selectedParking);
              notifyListeners();
            },
            child: parking.zone == "Parking Relais" ?
            Image.asset(
              "assets/images/icone_parking_relais.png",
            )
            : Image.asset(
              "assets/images/icone_parking.png",
              color: parking.isClosed != null ?
                !parking.isClosed! ? Colors.blue : Colors.red
                : Colors.blue,
            ),
          )));
    }
    _markers.clear(); //? useless ?
    _markers = markers;
  }

  // Renvoie les la liste des markers
  List<Marker> getParkingsMarkers() {
    return _markers;
  }

   // Récupère Parking depuis les coordonnées

  static Parking getParkingFromCoordinates(LatLng point) {
    return _parkings.firstWhere((parking) =>
        parking.coordinates[1] == point.latitude &&
        parking.coordinates[0] == point.longitude);
  }

  /// Récupère et rénvoie la propriété available depuis les coordonnées
  static String? getAvailableFromCoordinates(LatLng point) {
    Parking parkingPopup = _parkings.firstWhere((parking) =>
        parking.coordinates[1] == point.latitude &&
        parking.coordinates[0] == point.longitude);
    return parkingPopup.available;
  }

  /// Récupère et rénvoie la propriété uiColor_en depuis les coordonnées
  static Color? getColorFromCoordinates(LatLng point) {
    Parking parkingPopup = _parkings.firstWhere((parking) =>
        parking.coordinates[1] == point.latitude &&
        parking.coordinates[0] == point.longitude);

    switch (parkingPopup.colorText) {
      case "blue":
        {
          return Colors.blue;
        }

      case "orange":
        {
          return Colors.orange;
        }

      case "green":
        {
          return Colors.green;
        }

      case "red":
        {
          return Colors.red;
        }

      default:
        {
          return Colors.black;
        }
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
    super.removeListener(listener);
    if (kDebugMode) {
      print("removeListener here");
    }
  }
}
