import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mscl_engineer/Controller/locale_model.dart';
import 'package:mscl_engineer/Utils/Constant/app_pages_names.dart';
import 'package:mscl_engineer/Views/Widgets/buttons.dart';
import 'package:mscl_engineer/color.dart';

class StartingScreen extends StatefulWidget {
  const StartingScreen({super.key});

  @override
  State<StartingScreen> createState() => _StartingScreenState();
}

class _StartingScreenState extends State<StartingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfafafa),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/logo1.jpg"),
          const SizedBox(height: 35,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomFillButton(buttontext: "English", buttontextsize: 16,buttoncolor: maincolor, onPressed: (){
                 Provider.of<LanguageProvider>(context, listen: false).setLocale('en');
                 Navigator.pushNamed(context, AppPageNames.loginScreen);
              }, minimumSize: const Size(151, 52)),
              OutlineButtonCustom(buttontext: "தமிழ்", buttoncolor: maincolor, onPressed: (){
                 Provider.of<LanguageProvider>(context, listen: false).setLocale('ta');
                 Navigator.pushNamed(context, AppPageNames.loginScreen);
              }, minimumSize: const Size(150, 52), buttontextsize: 16,)
            ],
          )
        ],
      ),
    );
  }
}