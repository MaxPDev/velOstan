import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:http/http.dart';

import 'package:nancy_stationnement/screens/home_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:nancy_stationnement/services/gny_parking.dart';
import 'package:nancy_stationnement/services/ban_service.dart';
import 'package:nancy_stationnement/services/jcdecaux_velostan.dart';
import 'package:nancy_stationnement/services/store.dart';

///
/// Fonction main
///
void main() async {
  //! Could be not safe (https permissions)
  HttpOverrides.global = new MyHttpOverrides();

  // Splashscreen longer
  //TODO if FlutterNativeSpash.remove is not setup after initialization,
  //TODO no need of these two line
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GnyParking(),
        ),
        ChangeNotifierProvider(
          create: (context) => BanService(),
        ),
        ChangeNotifierProvider(
          create: (context) => JcdecauxVelostan(),
        ),
        ChangeNotifierProvider(
          create: (context) => Store(),
        )
      ],
      child: MaterialApp(
        
        //todo: à mettre par défaut
        themeMode: ThemeMode.system,
        darkTheme: ThemeData.dark(),

        // Default theme
        theme: ThemeData(

          primaryColor: Color.fromARGB(255, 92, 212, 92),
          primaryColorLight: Color.fromARGB(255, 168, 207, 169),

          // top app bar theme
          appBarTheme: AppBarTheme(
            color: Color.fromARGB(255, 31, 77, 33),
            ),
          drawerTheme: DrawerThemeData(
            backgroundColor: Colors.green[200]
          ),

          // Parking card color
          cardColor: Color(0xFFE5E5E5),

          // main bottom app theme
          bottomAppBarColor: Color.fromARGB(255, 92, 212, 92)
        ),
        //TODO: Set it to false in release version
        debugShowCheckedModeBanner: true,
        //TODO:vmanage here themeMode
        home: NancyStationnementApp(),
      )));
}

///
/// Classe principale
///
class NancyStationnementApp extends StatelessWidget {
  const NancyStationnementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bloquer l'appli en mode portrait //? Temporaire
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    return const SafeArea(
      child: HomeScreen()
    );
  }
}


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
//? Peut-être utile à un moment : 
// allowAutoSignedCert = true;

