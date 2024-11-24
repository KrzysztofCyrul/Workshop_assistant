import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/workshop/workshop_list_screen.dart';
// Importuj inne ekrany

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    LoginScreen.routeName: (context) => LoginScreen(),
    RegisterScreen.routeName: (context) => RegisterScreen(),
    HomeScreen.routeName: (context) => HomeScreen(),
    WorkshopListScreen.routeName: (context) => WorkshopListScreen(),
    // Dodaj inne trasy tutaj
  };
}
