import 'package:flutter/material.dart';
import 'package:nancy_stationnement/widgets/to_route_app.dart';

import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nancy_stationnement/models/parking.dart';
import 'package:nancy_stationnement/utils/hex_color.dart';
import 'package:nancy_stationnement/services/gny_parking.dart';
import 'package:nancy_stationnement/widgets/items.dart';
import 'package:nancy_stationnement/text/app_text.dart' as text;

class MinParkingCard extends StatelessWidget {
  const MinParkingCard({
    Key? key,
    // required this.gny,
  }) : super(key: key);

  // final GnyParking Function(BuildContext context, {bool listen}) gny;

      // Providers
  final gny = Provider.of<GnyParking>;
  // double cardHeight = 54;

  //? faire évoluer par charging/pmr/max si besoin d'autres conditions :
  //? discerner null et 0.
  static String dataToPrint(data) {
    if((data == null) || (data == "null")) {
      return "-";
    }
    return data;
  }

  final double? sizedBoxHeighMiddle = 7;
  final double? sizedBoxHeighBottom = 9;

  //! If parking is closed !

  @override
  Widget build(BuildContext context) {
  Parking parking = gny(context, listen: true).selectedParking!;
  double width = MediaQuery.of(context).size.width;
    return SizedBox(
        // height: 54,
        child: Column(
          children: [
            // Flèche d'agrandissement
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  height: 12,
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 20),
                ),
              ],
            ),
            DividerQuart(width: width),

            // Zone ou Parking Relais
           parking.zone != null ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // parking.zone != "Parking Relais" ? "${parking.zone}" : "${parking.zone}",
                  "${parking.zone}",
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: Theme.of(context).textTheme.overline
                  // style: TextStyle(
                  //   fontWeight: FontWeight.normal,
                  //   fontStyle: FontStyle.italic,
                  //   fontSize: 16,
                  //   overflow: TextOverflow.ellipsis
                  // ),
                ),
              ],
            ) : Container(),
            parking.zone != null ? DividerQuart(width: width) : Container(),

            // Affichage si parking fermé
            parking.isClosed != null ?
              parking.isClosed == true ?
                const Text(
                  text.parkingClosed, 
                  style: TextStyle(
                    color: Colors.red, 
                    fontSize: 15,
                    fontWeight: FontWeight.bold))
                : Container()
            : Container(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nom de du Parking
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesomeIcons.squareParking,
                        size: 24,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        height: sizedBoxHeighMiddle,
                      ),
                      Text(
                        "${parking.name}",
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.headline4,
                        // style: TextStyle(
                        //   fontWeight: FontWeight.bold,
                        //   fontSize: 16,
                        //   overflow: TextOverflow.ellipsis
                        // ),
                      ),
                    ],
                  ),
                ),
                // Affichage place PMR
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesomeIcons.wheelchair,
                        size: 18
                      ),
                      SizedBox(
                        height: sizedBoxHeighMiddle,
                      ), 
                      Text(dataToPrint(parking.disabled)) 
                      ],
                  ),
                ),
                // Affichage borne de recharge electrique
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesomeIcons.chargingStation,
                        size: 18
                      ),
                      SizedBox(
                        height: sizedBoxHeighMiddle,
                      ), 
                      Text(dataToPrint(parking.charging)) 
                      ],
                  ),
                ),
                // Affichage Disponibilité
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      
                      // Disponibilité si info disponible pour ce parking
                      parking.available != "null" ? 
                      // Affichage si disponibilité reçu
                        parking.available != null ?
                          Text(
                            "${parking.available} ${text.places}",
                            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              color: HexColor(parking.colorHexa!)
                            ),
                          )
                          // Affichage si disponibilité non reçu (connexion)
                          : Text(
                              text.unknownPlaces,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                color: Colors.indigo
                              )
                            )
                       : const Text(""),
                      ],
                  ),
                ),
              ],
            ),
            DividerQuart(width: width),

            SizedBox(
              width: width/3,
              child: ToRouteApp(
                parking: parking)),

            SizedBox(
              height: sizedBoxHeighBottom,
            ),
          ],
        ),
      );
  }
}