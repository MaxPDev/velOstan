import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:nancy_stationnement/services/store.dart';
import 'package:nancy_stationnement/services/gny_parking.dart';
import 'package:nancy_stationnement/text/app_text.dart' as text;

class SideBar extends StatelessWidget {
  const SideBar({
    Key? key,
    required this.updateParking,
  }) : super(key: key);

  ///* provider du service G-Ny
  final gny = Provider.of<GnyParking>;

  ///* Provider du service Store
  final store = Provider.of<Store>;

  final Function updateParking;

  @override
  Widget build(BuildContext context) {

    return Drawer(
      // backgroundColor: Colors.green[200],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          // Header Logo + Nom de l'applicatin
          DrawerHeader(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(21)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Image(
                        width: 70,
                        height: 70,
                        image: AssetImage('assets/images/logo.png'),
                        )
                    ],
                  ),
                  const SizedBox(
                    width: 54,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Parking",
                            style: Theme.of(context).textTheme.headline1
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Nancy",
                            style: Theme.of(context).textTheme.headline1
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              )
            ),
          ),

          // Mise à jour des données de parkings
          ListTile(
            title: Text(
              text.parkingUpdate,
              style: Theme.of(context).textTheme.bodyText1),
            subtitle: const Text(
              text.parkingUpdateDescr,
              // style: Theme.of(context).textTheme.bodyText1,  
            ),
            onTap: () {
              updateParking();
              store(context, listen: false).userSelection = "parkings";

              Scaffold.of(context).closeDrawer();

            },
          ),
          const ListTile(
            title: Text(text.aboutTitle),
            subtitle: Text(text.aboutDescr),
          ),
        ],
      ),
    );
  }
}