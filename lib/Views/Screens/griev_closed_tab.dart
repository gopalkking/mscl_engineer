import 'package:flutter/material.dart';
import 'package:mscl_engineer/Utils/Constant/app_pages_names.dart';
import 'package:mscl_engineer/Views/Screens/allitem.dart';
import 'package:mscl_engineer/Views/Screens/recent_closed_screen.dart';
import 'package:mscl_engineer/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GrievClosedTab extends StatefulWidget {
    final int? selectedindex;
  const GrievClosedTab({super.key, this.selectedindex});

  @override
  State<GrievClosedTab> createState() => _GrievClosedTabState();
}

class _GrievClosedTabState extends State<GrievClosedTab> 
  with SingleTickerProviderStateMixin {
  late TabController _tabController;
      late int _selectedIndex;



  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
       _selectedIndex = widget.selectedindex ?? 0; 
       _tabController.index = _selectedIndex;
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
      List<String> tabs = [
      AppLocalizations.of(context)!.currentgriev,
      AppLocalizations.of(context)!.recentclosed,
    ];
    return DefaultTabController(
      length: tabs.length, // Same length as _tabs and _tabContent
      initialIndex: _selectedIndex,
      child: Scaffold(
        backgroundColor: kbackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => Navigator.pushNamed(context, AppPageNames.homeScreen),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          title: const Text('Grievance List', style: TextStyle(fontWeight: FontWeight.w500)),
          bottom:  PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1.0)],
              ),
              height: 0.8,
            ),
          ),
        ),
        body: Column(
          children: [
            TabBar(
               controller: _tabController,
              padding: const EdgeInsets.all(8),
              indicatorColor: maincolor, // Adjust as needed
              tabs: List.generate(
                tabs.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                        color: _tabController.index == index
                            ? maincolor
                            : Colors.grey,
                        fontSize: 18.0),
                  ),
                ),
              ),
              
            ),
            Expanded(
              child: TabBarView(
                 controller: _tabController,
                children: const [
                  AllItem(),
                  RecentClosedScreen()
                ], 
              ),
            ),
          ],
        ),
      ),
    );
  }
}