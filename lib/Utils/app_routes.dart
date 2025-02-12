import 'package:flutter/material.dart';
import 'package:mscl_engineer/Utils/Constant/app_pages_names.dart';
import 'package:mscl_engineer/Views/Screens/Authentication/change_password.dart';
import 'package:mscl_engineer/Views/Screens/Authentication/forget_password.dart';
import 'package:mscl_engineer/Views/Screens/Authentication/login_screen.dart';
import 'package:mscl_engineer/Views/Screens/edit_screen.dart';
import 'package:mscl_engineer/Views/Screens/griev_closed_tab.dart';
import 'package:mscl_engineer/Views/Screens/home_screen.dart';
import 'package:mscl_engineer/Views/Screens/language_screen.dart';
import 'package:mscl_engineer/Views/Screens/profile_screen.dart';
import 'package:mscl_engineer/Views/Screens/splash_screen.dart';


class AppRouteGenerator{

static Route<dynamic> generateRoute(RouteSettings settings){

switch(settings.name)
{
  case AppPageNames.rootScreen:
   case AppPageNames.splashscreen:
    return pageRoute(const StartingScreen());
  case AppPageNames.loginScreen:
    return pageRoute(const LoginScreen());
  case AppPageNames.homeScreen:
    return pageRoute(const HomeScreen());
  case AppPageNames.grievancePage:
    return pageRoute(const GrievClosedTab());
  case AppPageNames.profileScreen:
    return pageRoute(const ProfileScreen());
  case AppPageNames.languageScreen:
    return pageRoute(const LanguageScreen());
  case AppPageNames.changePassword:
    return pageRoute(const ChangePassword());
  case AppPageNames.editScreen:
    return pageRoute(const EditScreen());
  case AppPageNames.forgetPassword:
    return pageRoute(const ForgetPassword());  
  
  
  



   default:
        // Open this page if wrong route address used
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                body: SafeArea(child: Center(child: Text('Page not found')))));

}
}
}

PageRoute pageRoute(Widget page) {
  return PageRouteBuilder(
   // transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) =>  page,
     transitionsBuilder: (context, animation, secondaryAnimation, child) {
       return FadeTransition(opacity: animation,child: child,);
    },
  );
} 
