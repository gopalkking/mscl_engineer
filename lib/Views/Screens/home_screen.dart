// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mscl_engineer/Controller/complaint_controller.dart';
import 'package:mscl_engineer/Controller/dept_request.dart';
import 'package:mscl_engineer/Controller/grievance_detail.dart';
import 'package:mscl_engineer/Controller/status_controller.dart';
import 'package:mscl_engineer/Controller/user_count.dart';
import 'package:mscl_engineer/Model/complaintdetail.dart';
import 'package:mscl_engineer/Model/dept_model.dart';
import 'package:mscl_engineer/Model/grievance_model.dart';
import 'package:mscl_engineer/Model/status.dart';
import 'package:mscl_engineer/User%20preferences/customer_current.dart';
import 'package:mscl_engineer/Utils/Constant/app_pages_names.dart';
import 'package:mscl_engineer/Views/Screens/allitem.dart';
import 'package:mscl_engineer/Views/Screens/drawer/escalation.dart';
import 'package:mscl_engineer/Views/Screens/griev_closed_tab.dart';
import 'package:mscl_engineer/Views/Screens/reply_complaint.dart';
import 'package:mscl_engineer/Views/Screens/session_handling.dart';
import 'package:mscl_engineer/Views/Widgets/loading.dart';
import 'package:mscl_engineer/Views/Widgets/my_header_drawer.dart';
import 'package:mscl_engineer/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

class GDPdata {
  final String continent;
  final int gdp;
  final Color color;

  GDPdata({required this.continent, required this.gdp, required this.color});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<GDPdata> _chartData;
  late List<GDPdata> _chartData2;
  List<Grievance> grievanceData = [];
  final UserController _userController = UserController();
  final CustomerCurrentUser _customer = Get.put(CustomerCurrentUser());
  final GrievanceController getuserid = Get.put(GrievanceController());
  final StatusController statusController = Get.put(StatusController());
  final DeptController departmentController = Get.put(DeptController());
  final ComplaintController complaintController =
      Get.put(ComplaintController());
  late Future<List<GDPdata>> _chartDataFuture;
  late Future<List<GDPdata>> _chartDataFuture2;
  int maxCount = 10;

  @override
  void initState() {
    super.initState();
    _customer.getUserInfo();
    _loadUserData();
    _chartDataFuture2 = fetchChartData2();
    _chartDataFuture = fetchChartData();
    // complaintController.fetchGrievance1(_customer.customer.userId.toString());

    SessionExpirationHandler.startChecking(context);
  }

  Future<void> _loadUserData() async {
    await _userController.fetchUserData();
    setState(() {});
  }

  List<Color> chartColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.pink,
    Colors.yellow,
  ];

  Future<List<GDPdata>> fetchChartData2() async {
    List<DeptModel> fetchedDept = await departmentController.getAllDept();

    await _userController.fetchUserData();

    List<GDPdata> chartData1 = fetchedDept.map((dept) {
      String deptName = dept.deptName.trim().toLowerCase();
      String matchingDeptName = _userController.deptCounts.keys.firstWhere(
          (key) => key.toLowerCase() == deptName,
          orElse: () => deptName);

      int count = _userController.deptCounts[matchingDeptName] ?? 0;
      Color color = chartColors[fetchedDept.indexOf(dept) % chartColors.length];

      return GDPdata(
        continent: dept.deptName,
        gdp: count,
        color: color,
      );
    }).toList();

    return chartData1;
  }

  Future<List<GDPdata>> fetchChartData() async {
    List<StatusModel> fetchedStatus = await statusController.getAllStatus();

    await _userController.fetchUserData();

    List<GDPdata> chartData = fetchedStatus.map((status) {
      String statusName =
          status.statusname.trim().toLowerCase(); // Ensure consistency
      int count = _userController.statusCounts[statusName] ??
          0; // Default to 0 if status is not found

      // int count = _userController.statusCounts[status.statusname] ?? 0;
      return GDPdata(
        continent: status.statusname,
        gdp: count,
        color: status.color,
      );
    }).toList();

    return chartData;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.green;
      case 'new':
        return Colors.blue;
      case 'Closed':
        return const Color.fromRGBO(0, 63, 91, 1);
      case 'On Hold':
        return Colors.blue;
      case 'Resolved':
        return Colors.green.shade900;
      default:
        return Colors.green;
    }
  }

  Color getStatusColor2(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Low':
        return Colors.green;
      case 'Critical':
        return Colors.blue;
      case 'Medium':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat formatter = DateFormat('MMMM dd yyyy, hh:mm a');
    return formatter.format(dateTime);
  }

  String formatDay(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat formatter = DateFormat('EEEE, dd MMMM');
    return formatter.format(dateTime);
  }

  String formatTime(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat timeFormatter = DateFormat('hh:mm a');
    return timeFormatter.format(dateTime);
  }

  String formatTimeAgo(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    return timeago.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
        future: getuserid.fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final user = getuserid.userModel.value;
            return Scaffold(
              backgroundColor: kbackgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(
                    color: Colors.black), // Ensure the drawer icon is visible
                title: Text(
                  user.userName ?? " ",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0.5),
                  child: Container(
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(color: Colors.grey, blurRadius: 1.0)
                    ]),
                    height: 0.8,
                  ),
                ),
              ),
              drawer: Drawer(
                backgroundColor: Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    const MyHeaderDrawer(),
                    const Divider(
                      color: Colors.black,
                    ),
                    ListTile(
                      leading: const Icon(Icons.dashboard),
                      title: Text(
                        AppLocalizations.of(context)!.dashboard,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        "assets/icons/Component 1.svg",
                        color: Colors.black,
                        height: 28,
                        width: 28,
                      ),
                      title: Text(AppLocalizations.of(context)!.griev),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GrievClosedTab(
                                      selectedindex: 0,
                                    )));
                      },
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        "assets/icons/Vector2.svg",
                        color: Colors.black,
                        height: 28,
                        width: 28,
                      ),
                      title: Text(AppLocalizations.of(context)!.escla),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Escalation()));
                      },
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: Text(AppLocalizations.of(context)!.settings),
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppPageNames.profileScreen);
                      },
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const GrievClosedTab(
                                                selectedindex: 0,
                                              )));
                                },
                                child: Container(
                                  width: screenWidth * 0.27,
                                  //height: screenHeight*0.10,
                                  decoration: BoxDecoration(
                                      //boxShadow: const [BoxShadow(color: Colors.black,blurRadius: 1)],
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color.fromRGBO(
                                          255, 240, 240, 1)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${_userController.itemCount}',
                                              style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w500),
                                            ),

                                            // SizedBox(width: 30,),
                                            const Image(
                                              image: AssetImage(
                                                  "assets/icons/user_check-1.jpg"),
                                              height: 29,
                                              width: 29,
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .allreq,
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Escalation()));
                                },
                                child: Container(
                                  width: screenWidth * 0.27,
                                  //  height: screenHeight*0.10,
                                  decoration: BoxDecoration(
                                      //boxShadow: const [BoxShadow(color: Colors.black,blurRadius: 1)],
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color.fromRGBO(
                                          218, 213, 248, 1)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            FutureBuilder(
                                                future: complaintController
                                                    .fetchGrievance1(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      color: Colors.black,
                                                    );
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                        child: Text(
                                                            'Error :${snapshot.hasError}'));
                                                  } else {
                                                    final escalationcount =
                                                        snapshot.data!;
                                                    var escalation =
                                                        escalationcount
                                                            .where((count) =>
                                                                count
                                                                    .isEsacalted ==
                                                                'yes')
                                                            .toList();
                                                    return Text(
                                                      '${escalation.length}',
                                                      style: const TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    );
                                                  }
                                                }),
                                            // const SizedBox(width: 30,),
                                            const Image(
                                              image: AssetImage(
                                                  "assets/icons/hot_request-1.jpg"),
                                              height: 29,
                                              width: 29,
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .hotreq,
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const GrievClosedTab(
                                                selectedindex: 1,
                                              )));
                                },
                                child: Container(
                                  width: screenWidth * 0.27,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color.fromRGBO(
                                          225, 255, 245, 1)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${_userController.closedCount}',
                                              style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const Image(
                                              image: AssetImage(
                                                  "assets/icons/all_open-1.jpg"),
                                              height: 29,
                                              width: 29,
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .allopen,
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)!.recent,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const GrievClosedTab(
                                                    selectedindex: 0,
                                                  )));
                                    },
                                    child: const Text(
                                      'View All',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.green),
                                    ))
                              ],
                            ),
                          ),
                          FutureBuilder(
                              future: complaintController.fetchGrievance1(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child:
                                          Text('Error :${snapshot.hasError}'));
                                } else {
                                  List<TicketModel> grievance = snapshot.data!;
                                  final filtergrievance = grievance
                                      .where((status) =>
                                          status.status == "processing")
                                      .toList();
                                  if (filtergrievance.isEmpty) {
                                    return const Center(
                                        child: Text('No data available'));
                                  }
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(0),
                                      itemCount:
                                          min(maxCount, filtergrievance.length),
                                      itemBuilder: (context, index) {
                                        final String formattedDate = formatDate(
                                            filtergrievance[index]
                                                .createdAt
                                                .toString());
                                        final String timeago = formatTimeAgo(
                                            filtergrievance[index]
                                                .createdAt
                                                .toString());
                                        final String formattedTime = formatTime(
                                            filtergrievance[index]
                                                .createdAt
                                                .toString());
                                        final String formattedTime2 =
                                            formatTime(filtergrievance[index]
                                                .updatedAt
                                                .toString());
                                        final String formattedday2 = formatDay(
                                            filtergrievance[index]
                                                .updatedAt
                                                .toString());
                                        final String formattedday = formatDay(
                                            filtergrievance[index]
                                                .createdAt
                                                .toString());
                                        return AllList(
                                          containerColor: Colors.white,
                                          statusLabel: getStatusColor(
                                              filtergrievance[index]
                                                  .status
                                                  .toString()),
                                          status: filtergrievance[index]
                                              .status
                                              .toString(),
                                          status2: filtergrievance[index]
                                              .priority
                                              .toString(),
                                          statusLabel2: getStatusColor2(
                                              filtergrievance[index]
                                                  .priority
                                                  .toString()),
                                          username: filtergrievance[index]
                                              .publicUsername
                                              .toString(),
                                          comtitile: filtergrievance[index]
                                              .complainttypetitle
                                              .toString(),
                                          depart: filtergrievance[index]
                                              .deptname
                                              .toString(),
                                          createddate: filtergrievance[index]
                                              .createdAt
                                              .toString(),
                                          updatedate: filtergrievance[index]
                                              .updatedAt
                                              .toString(),
                                          ward: filtergrievance[index]
                                              .ward
                                              .toString(),
                                          zone: filtergrievance[index]
                                              .zone
                                              .toString(),
                                          street: filtergrievance[index]
                                              .street
                                              .toString(),
                                          phone: filtergrievance[index]
                                              .phone
                                              .toString(),
                                          statusflow: filtergrievance[index]
                                              .statusflow
                                              .toString(),
                                          assign: filtergrievance[index]
                                              .assingusername
                                              .toString(),
                                          grievid: filtergrievance[index]
                                              .grievanceid
                                              .toString(),
                                          pincode: filtergrievance[index]
                                              .pincode
                                              .toString(),
                                          complaindisc: filtergrievance[index]
                                              .complaintdetails
                                              .toString(),
                                          complaint: filtergrievance[index]
                                              .complaint
                                              .toString(),
                                          lat: filtergrievance[index]
                                              .lat
                                              .toString(),
                                          lon: filtergrievance[index]
                                              .lon
                                              .toString(),
                                          icon: const SizedBox(),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            ReplyComplaint(
                                                              status:
                                                                  filtergrievance[
                                                                          index]
                                                                      .status
                                                                      .toString(),
                                                              username: filtergrievance[
                                                                      index]
                                                                  .publicUsername
                                                                  .toString(),
                                                              comtitile:
                                                                  filtergrievance[
                                                                          index]
                                                                      .complainttypetitle
                                                                      .toString(),
                                                              depart:
                                                                  filtergrievance[
                                                                          index]
                                                                      .deptname
                                                                      .toString(),
                                                              createddate:
                                                                  formattedDate,
                                                              updatedate:
                                                                  formattedTime2,
                                                              ward: filtergrievance[
                                                                      index]
                                                                  .ward
                                                                  .toString(),
                                                              zone: filtergrievance[
                                                                      index]
                                                                  .zone
                                                                  .toString(),
                                                              street:
                                                                  filtergrievance[
                                                                          index]
                                                                      .street
                                                                      .toString(),
                                                              phone:
                                                                  filtergrievance[
                                                                          index]
                                                                      .phone
                                                                      .toString(),
                                                              statusflow:
                                                                  filtergrievance[
                                                                          index]
                                                                      .statusflow
                                                                      .toString(),
                                                              assign: filtergrievance[
                                                                      index]
                                                                  .assingusername
                                                                  .toString(),
                                                              statusLabel: getStatusColor(
                                                                  filtergrievance[
                                                                          index]
                                                                      .status
                                                                      .toString()),
                                                              status2:
                                                                  filtergrievance[
                                                                          index]
                                                                      .priority
                                                                      .toString(),
                                                              statusLabel2: getStatusColor2(
                                                                  filtergrievance[
                                                                          index]
                                                                      .priority
                                                                      .toString()),
                                                              grievid:
                                                                  filtergrievance[
                                                                          index]
                                                                      .grievanceid
                                                                      .toString(),
                                                              pincode:
                                                                  filtergrievance[
                                                                          index]
                                                                      .pincode
                                                                      .toString(),
                                                              complaindisc:
                                                                  filtergrievance[
                                                                          index]
                                                                      .complaintdetails
                                                                      .toString(),
                                                              timeago: timeago,
                                                              createdtime:
                                                                  formattedTime,
                                                              formateddate:
                                                                  formattedday,
                                                              formateddate2:
                                                                  formattedday2,
                                                              complaint:
                                                                  filtergrievance[
                                                                          index]
                                                                      .complaint
                                                                      .toString(),
                                                              lat: filtergrievance[
                                                                      index]
                                                                  .lat
                                                                  .toString(),
                                                              lon: filtergrievance[
                                                                      index]
                                                                  .lon
                                                                  .toString(),
                                                              escalatenotify:
                                                                  filtergrievance[
                                                                          index]
                                                                      .escalationnotifyread,
                                                              escalatednode:
                                                                  filtergrievance[
                                                                          index]
                                                                      .escalationnotify,
                                                            )));
                                          },
                                        );
                                      });
                                }
                              }),
                          const SizedBox(height: 24),
                          FutureBuilder<List<GDPdata>>(
                            future: _chartDataFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text('No data available');
                              } else {
                                _chartData2 = snapshot.data!;
                                return _buildChart(
                                    _chartData2,
                                    AppLocalizations.of(context)!
                                        .openreqstatusdisc);
                              }
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          FutureBuilder<List<GDPdata>>(
                            future: _chartDataFuture2,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text('No data available');
                              } else {
                                _chartData = snapshot.data!;
                                return _buildChart(
                                    _chartData,
                                    AppLocalizations.of(context)!
                                        .daycomptypedisc);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  Widget _buildChart(List<GDPdata> chartData, String title) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(
              height: 250,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      width: 300,
                      child: SfCircularChart(
                        legend: const Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          overflowMode: LegendItemOverflowMode.wrap,
                          itemPadding: 5,
                        ),
                        series: <CircularSeries>[
                          DoughnutSeries<GDPdata, String>(
                            dataSource: chartData,
                            xValueMapper: (GDPdata data, _) => data.continent,
                            yValueMapper: (GDPdata data, _) => data.gdp.toInt(),
                            pointColorMapper: (GDPdata data, _) => data.color,
                            explode: true,
                            explodeAll: true,
                            innerRadius: '70%',
                            explodeOffset: '2.5',
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                              useSeriesColor: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
