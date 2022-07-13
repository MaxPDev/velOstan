import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nancy_stationnement/utils/hex_color.dart';
import 'package:nancy_stationnement/services/gny_parking.dart';
import 'package:nancy_stationnement/models/parking.dart';

class ParkingCard extends StatelessWidget {
  const ParkingCard({
    Key? key,
  }) : super(key: key);

  final gny = Provider.of<GnyParking>;

  //TODO: Peut être changer les adresse de mgn à OSM dans la récupération, ou l'inverse ! Bien décider

  //? faire évoluer par charging/pmr/max si besoin d'autres conditions :
  //? discerner null et 0.
  static String dataToPrint(data) {
    if((data == null) || (data == "null")) {
      return "-";
    }
    return data;
  }

  static String priceToPrint(price) {
    if((price == null) || (price == "null") || (price == "-")) {
      return "-";
    }
    if(price == "free") {
      return "Gratuit";
    }
    return "$price €";
  }

  static String typeToPrint(type) {
    if((type == null) || (type == "null")) {
      return "-";
    }
    if(type == "underground") {
      return "souterrain";
    }
    if(type == "multi-storey") {
      return "à étages";
    }
    if(type == "surface") {
      return "au sol";
    }
    return type;
  }

  static String operatorToPrint(operator) {
    if(operator == null || operator == "null") {
      return "-";
    }
    return operator;
  }

  //? Mettre les conditions sur les colonnes plutôt que 0 ? Dans certains cas ?
  //? Voir en fonction de la réalité...

  @override
  Widget build(BuildContext context) {

    // Parking détaillé dans la card
    Parking parking = gny(context, listen: true).selectedParking!;
    inspect(parking);

    final double? normalTextCardFontSize = 15; //TODO: GLOBAL (défaut : 14)
    
    // Conversion du lien du parking, si disponible, en Uri
    late Uri _url;
    if(parking.website != null) {
      _url = Uri.parse(parking.website!);
    }

    // Conversion du téléphone, si disponible, en Uri (url_launcher)
    late Uri _tel;
    if(parking.phone != null) {
      _tel = Uri.parse("tel:" + parking.phone!);
    }

    // Portrait ou Paysage
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Variables de hauteurs d'écrans
    // Full screen width and height
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // TODO GLOBAL
    // Height (without SafeArea)
    var padding = MediaQuery.of(context).viewPadding;
    double height1 = height - padding.top - padding.bottom;

    // Height (without status bar)
    double height2 = height - padding.top;

    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;

    return isPortrait ?
    Container(
      padding: EdgeInsets.all(7),
      height: height3 * 0.54,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 3.0
          ),
        ),

      ),
      child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icone, Nom du Parking et sa disponbilité
          Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
            Column(
              children: [
                // Icone et Nom du parking
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.squareParking,
                      size: 24,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 10,
                    ),                 
                    Text("${parking.name}",
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                // Disponibilité si info disponible
                parking.available != "null"
                    ? Text(
                        "${parking.available} places",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          //! Prévoir un cas nullable pour ne pas être bloquant
                          color: HexColor(parking.colorHexa!),
                        ),
                      )
                    : Text(""),
              ],
            )
          ]),
          // Capacité Max, PMR et Bornes de recharge électrique
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Capacité
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text("Capacité : ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: normalTextCardFontSize))
                  ],
                ),
              ),
              // Capacité max
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text("Max.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: normalTextCardFontSize)),
                    Text(dataToPrint(parking.capacity), style: TextStyle(fontSize: normalTextCardFontSize),)
                  ],
                ),
              ),
              // PMR
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Icon(FontAwesomeIcons.wheelchair, size: 18),
                    Text(dataToPrint(parking.disabled), style: TextStyle(fontSize: normalTextCardFontSize))
                  ],
                ),
              ),
              // Bornes de recharge
              Expanded(
                flex: 3,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.chargingStation, size: 18),
                    Text(dataToPrint(parking.charging), style: TextStyle(fontSize: normalTextCardFontSize))
                  ],
                ),
              ),
            ],
          ),
          // Tarifs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tarifs
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Text("Tarif : ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: normalTextCardFontSize))
                  ],
                ),
              ),
              // Tarif 30 min
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text("30 min",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: normalTextCardFontSize)),
                    Text(priceToPrint(parking.prices!['30']), style: TextStyle(fontSize: normalTextCardFontSize),)
                  ],
                ),
              ),

              // Tarif 60 min
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text("1h",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: normalTextCardFontSize)),
                    Text(priceToPrint(parking.prices!['60']), style: TextStyle(fontSize: normalTextCardFontSize))
                  ],
                ),
              ),

              // Tarif 120 min
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text("2h",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: normalTextCardFontSize)),
                    Text(priceToPrint(parking.prices!['120']))
                  ],
                ),
              ),

              // Tarif 240 min
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text("4h",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: normalTextCardFontSize)),
                    Text(priceToPrint(parking.prices!['240']), style: TextStyle(fontSize: normalTextCardFontSize),)
                  ],
                ),
              ),

            ],
          ),
          // Type et Haute du parking
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              // Type Hauteur
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text("Hauteur max : ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: normalTextCardFontSize)),
                    Text(dataToPrint(parking.maxHeight), style: TextStyle(fontSize: normalTextCardFontSize),),
                  ],
                ),
              ),

              // Type parking
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text("Type : ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: normalTextCardFontSize)),
                    Text(typeToPrint(parking.type), style: TextStyle(fontSize: normalTextCardFontSize))
                  ],
                ),
              ),
            ],
          ),

          // Adresse
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Adresse
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.house,
                      size: 18
                    ),
                    // OSM
                    // Text(dataToPrint(parking.addressNumber)),
                    // Text(dataToPrint(parking.addressStreet)),
                    // MGN
                    Text(
                      dataToPrint(parking.address),
                      style: TextStyle(
                        overflow: TextOverflow.clip,
                        fontSize: normalTextCardFontSize
                      ),)
                  ],
                ),
              ),
            ],
          ),
          // Téléphone et Site Web
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              // Téléphone
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.phone,
                      size: 18
                    ),
                    parking.phone != null ? InkWell(
                      child: Text('${parking.phone}', style: TextStyle(color: Colors.blue, fontSize: normalTextCardFontSize),),
                      onTap: () => launchUrl(_tel),
                    ) :
                    Text("-"),
                  ],
                ),
              ),
              
              // Site Web
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.globe,
                      size: 18
                    ),
                    parking.website != null ? InkWell(
                      child: Text('Site Web', style: TextStyle(color: Colors.blue, fontSize: normalTextCardFontSize),),
                      onTap: () => launchUrl(_url),
                    ) :
                    Text("-")
                  ],
                ),
              ),


            ],
          ),

          // Propriétaire
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              // Type Hauteur
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text("Propriétaire: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: normalTextCardFontSize),),
                    Text(operatorToPrint(parking.operator), style: TextStyle(fontSize: normalTextCardFontSize))
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ) : 

    // Affichage Landscape
    //! PROBLEME LORSQUE JE REMPLIE AVEC PLUS D'AUTRE CONTENU : RENDER FLEX. PARCEQUE SCROLLABLE ?
    Container(
      height: height3 * 0.30,
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                                    // Icone et Nom du parking
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.squareParking,
                          size: 24,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          width: 10,
                        ),                 
                        Text("${parking.name}",
                            style:
                                TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    // Disponibilité si info disponible
                    parking.available != "null"
                        ? Text(
                            "${parking.available} places",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              //! Prévoir un cas nullable pour ne pas être bloquant
                              color: HexColor(parking.colorHexa!),
                            ),
                          )
                        : Text(""),
                  
                  ],
                ),
                
                
              ],
            ),
          )
        ]),
    );
  }
}