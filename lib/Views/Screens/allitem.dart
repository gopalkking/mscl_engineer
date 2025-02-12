import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mscl_engineer/Controller/grievance_page_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mscl_engineer/Model/status.dart';
import 'package:mscl_engineer/Views/Screens/reply_complaint.dart';

class AllItem extends StatefulWidget {
  const AllItem({super.key});

  @override
  State<AllItem> createState() => _AllItemState();
}

class _AllItemState extends State<AllItem> {
  final TextEditingController _searchController = TextEditingController();

  final GrievancePageController grievancepage =
      Get.put(GrievancePageController());

  @override
  void initState() {
    super.initState();
    grievancepage.fetchcomplaint();
    grievancepage.fetchStatusData();

    _searchController.addListener(() {
      _filterGrievanceData1();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool isLoading = false;

  void _filterGrievanceData1() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        final searchQuery = _searchController.text.toLowerCase();

        grievancepage.filteredGrievanceData =
            grievancepage.grievanceData.where((grievance) {
          // Check if the search term matches any of the fields
          final matchesSearch = searchQuery.isEmpty ||
              grievance.grievanceId.toLowerCase().contains(searchQuery) ||
              grievance.phone.toLowerCase().contains(searchQuery);

          // Check if the grievance matches the selected status
          final matchesStatus = grievancepage.selectedStatus == null ||
              grievance.status.toLowerCase() ==
                  grievancepage.selectedStatus!.toLowerCase();

          return matchesSearch && matchesStatus;
        }).toList();

        isLoading = false;
      });
    });
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
     String allgriev = AppLocalizations.of(context)!.allgriev;
    return GetBuilder(
        init: grievancepage,
        builder: (context) {
          final sortedGrievances = grievancepage.filteredGrievanceData
              .where((grievance) =>
                  grievance.status == 'processing' ||
                  grievance.status == 'inprogress' ||
                  grievance.status == 'onhold')
              .toList()
            ..sort((a, b) {
              // Priority order for statuses
              List<String> priorityOrder = [
                'processing',
                'inprogress',
                'onhold'
              ];

              // Get the priority index of each status
              int priorityA = priorityOrder.indexOf(a.status.toLowerCase());
              int priorityB = priorityOrder.indexOf(b.status.toLowerCase());

              // If a status is not in the priority list, assign it the lowest priority
              if (priorityA == -1) priorityA = priorityOrder.length;
              if (priorityB == -1) priorityB = priorityOrder.length;

              // Compare by priority first
              int priorityComparison = priorityA.compareTo(priorityB);

              // If priorities are equal, compare by creation time (descending order)
              if (priorityComparison == 0) {
                return DateTime.parse(b.createdAt)
                    .compareTo(DateTime.parse(a.createdAt));
              }

              return priorityComparison;
            });
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _filterGrievanceData1(),
                    style: const TextStyle(color: Colors.black),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Text(
                        allgriev,
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: DropdownButton<String>(
                            value: grievancepage.selectedStatus,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.blue),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null, // This is the placeholder item
                                child: Text(
                                  'All', // Placeholder text
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              ...grievancepage.statusList
                                  .where(
                                      (status) => status.statusname != 'closed')
                                  .map<DropdownMenuItem<String>>(
                                      (StatusModel status) {
                                return DropdownMenuItem<String>(
                                  value: status.statusname,
                                  child: Text(status.statusname),
                                );
                              }),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                grievancepage.selectedStatus =
                                    newValue; // Update selected status
                                grievancepage
                                    .filterGrievanceData(); // Apply filtering
                              });
                            },
                            underline: Container(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // if (grievancepage.filteredGrievanceData.isNotEmpty)
                grievancepage.filteredGrievanceData.isEmpty || isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : grievancepage.filteredGrievanceData.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(8.0),
                            itemCount: sortedGrievances.length,
                            itemBuilder: (context, index) {
                              final grievance = sortedGrievances[index];
                              final String formattedDate =
                                  formatDate(grievance.createdAt);
                              final String timeago =
                                  formatTimeAgo(grievance.createdAt);
                              final String formattedTime =
                                  formatTime(grievance.createdAt);
                              final String formattedTime2 =
                                  formatTime(grievance.updatedAt);
                              final String formattedday2 =
                                  formatDay(grievance.updatedAt);
                              final String formattedday =
                                  formatDay(grievance.createdAt);
                              return AllList(
                                statusLabel: _getStatusColor(grievance.status),
                                containerColor: grievance.isEsacalted == 'yes'
                                    ? Colors.red.withOpacity(0.25)
                                    : grievance.isHighlighted == 'yes'
                                        ? Colors.yellowAccent.withOpacity(0.25)
                                        : Colors.white,
                                status: grievance.status,
                                status2: grievance.priority,
                                statusLabel2:
                                    _getStatusColor2(grievance.priority),
                                username: grievance.publicUserName,
                                comtitile: grievance.complaintTypeTitle,
                                createddate: grievance.createdAt,
                                assign: grievance.assignUsername,
                                depart: grievance.deptName,
                                phone: grievance.phone,
                                statusflow: grievance.statusflow,
                                street: grievance.streetName,
                                updatedate: grievance.updatedAt,
                                ward: grievance.wardName,
                                zone: grievance.zoneName,
                                grievid: grievance.grievanceId,
                                pincode: grievance.pincode,
                                complaindisc: grievance.complaintDetails,
                                complaint: grievance.complaint,
                                lat: grievance.lat.toString(),
                                lon: grievance.lon.toString(),
                                icon: grievance.escalationnotifyread == 'no'
                                    ? const Icon(
                                        Icons.chat,
                                        size: 30,
                                        color: Colors.red,
                                      )
                                    : const SizedBox(),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ReplyComplaint(
                                                status: grievance.status,
                                                username:
                                                    grievance.publicUserName,
                                                comtitile: grievance
                                                    .complaintTypeTitle,
                                                depart: grievance.deptName,
                                                createddate: formattedDate,
                                                updatedate: formattedTime2,
                                                ward: grievance.wardName,
                                                zone: grievance.zoneName,
                                                street: grievance.streetName,
                                                phone: grievance.phone,
                                                statusflow:
                                                    grievance.statusflow,
                                                assign:
                                                    grievance.assignUsername,
                                                statusLabel: _getStatusColor(
                                                    grievance.status),
                                                status2: grievance.priority,
                                                statusLabel2: _getStatusColor2(
                                                    grievance.priority),
                                                grievid: grievance.grievanceId,
                                                pincode: grievance.pincode,
                                                complaindisc:
                                                    grievance.complaintDetails,
                                                timeago: timeago,
                                                createdtime: formattedTime,
                                                formateddate: formattedday,
                                                formateddate2: formattedday2,
                                                complaint: grievance.complaint,
                                                lat: grievance.lat.toString(),
                                                lon: grievance.lon.toString(),
                                                escalatednode:
                                                    grievance.escalationnotify,
                                                escalatenotify: grievance
                                                    .escalationnotifyread,
                                              )));
                                },
                              );
                            },
                          )
                        : const Center(child: Text('No grievances to display')),
              ],
            ),
          );
        });
  }

  Color _getStatusColor(String status) {
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

  Color _getStatusColor2(String priority) {
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
}

class AllList extends StatelessWidget {
  final String grievid;
  final String status;
  final String username;
  final String comtitile;
  final String depart;
  final String complaindisc;
  final String createddate;
  final String updatedate;
  final String pincode;
  final String complaint;
  final String ward;
  final String zone;
  final String street;
  final String phone;
  final String statusflow;
  final String assign;
  final Color statusLabel;
  final String status2;
  final Color statusLabel2;
  final Color? containerColor;
  final String lat;
  final String lon;
  final Widget icon;
  final Function()? onTap;
  const AllList(
      {super.key,
      required this.statusLabel,
      required this.status,
      required this.status2,
      required this.statusLabel2,
      required this.username,
      required this.comtitile,
      required this.depart,
      required this.createddate,
      required this.updatedate,
      required this.ward,
      required this.zone,
      required this.street,
      required this.phone,
      required this.statusflow,
      required this.assign,
      required this.grievid,
      required this.pincode,
      required this.complaindisc,
      required this.complaint,
      required this.lat,
      required this.lon,
      this.containerColor,
      required this.icon,
      this.onTap});

  String formatTimeAgo(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    return timeago.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.blue[100],
                    child: SvgPicture.asset(
                      "assets/icons/profile.svg",
                      height: 45,
                      width: 45,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              grievid,
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: statusLabel),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                    color: statusLabel, fontSize: 12.0),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color:
                                    statusLabel2, // You can change the color based on priority
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                status2,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12.0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.raiseby,
                              style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(width: 3),
                            Text(username,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            icon,
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              Container(
                width: screenWidth * 0.27,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Center(
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.date,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            formatTimeAgo(createddate),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
