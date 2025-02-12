import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mscl_engineer/Controller/complaint_controller.dart';
import 'package:mscl_engineer/Model/grievance_model.dart';
import 'package:mscl_engineer/Utils/Constant/app_pages_names.dart';
import 'package:mscl_engineer/Views/Screens/allitem.dart';
import 'package:mscl_engineer/Views/Screens/reply_complaint.dart';
import 'package:mscl_engineer/color.dart';

class Escalation extends StatefulWidget {
  const Escalation({super.key,});

  @override
  State<Escalation> createState() => _EscalationState();
}

class _EscalationState extends State<Escalation> {


  final ComplaintController complaintController =
      Get.put(ComplaintController());

  @override
  void initState() {
    super.initState();
    complaintController.fetchGrievance1();
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
    return Scaffold(
      backgroundColor: kbackgroundColor,
       appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(onPressed: (){
               Navigator.pushNamed(context, AppPageNames.homeScreen);
            }, 
            icon:const Icon(Icons.arrow_back,color: Colors.black,)),
            title: const Text('Escalation List',style:  TextStyle(fontWeight: FontWeight.w500),),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(
                decoration: const BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1.0)]),
                height: 0.8,
              ),
            ),
          ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  const SizedBox(height: 20,),
                const Text(
                  'All Esclation',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 10),
                FutureBuilder(
                    future: complaintController.fetchGrievance1(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error :${snapshot.hasError}'));
                      } else {
                        List<TicketModel> grievance = snapshot.data!;
                        final filtergrievance = grievance
                            .where((status) => status.isEsacalted == 'yes')
                            .toList();
                        if (filtergrievance.isEmpty) {
                          return const Center(child: Text('No data available'));
                        }
                         
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(0),
                            itemCount: filtergrievance.length,
                            itemBuilder: (context, index) {
                               final String formattedDate = formatDate(filtergrievance[index].createdAt.toString());
          final String timeago = formatTimeAgo(filtergrievance[index].createdAt.toString());
        final String formattedTime = formatTime(filtergrievance[index].createdAt.toString());
        final String formattedTime2 = formatTime(filtergrievance[index].updatedAt.toString());
        final String formattedday2 = formatDay(filtergrievance[index].updatedAt.toString());
        final String formattedday = formatDay(filtergrievance[index].createdAt.toString());
                              return AllList(
                                containerColor:Colors.white,
                                statusLabel: getStatusColor(
                                    filtergrievance[index].status.toString()),
                                status: filtergrievance[index].status.toString(),
                                status2: filtergrievance[index].priority.toString(),
                                statusLabel2: getStatusColor2(
                                    filtergrievance[index].priority.toString()),
                                username: filtergrievance[index]
                                    .publicUsername
                                    .toString(),
                                comtitile: filtergrievance[index]
                                    .complainttypetitle
                                    .toString(),
                                depart: filtergrievance[index].deptname.toString(),
                                createddate:
                                    filtergrievance[index].createdAt.toString(),
                                updatedate:
                                    filtergrievance[index].updatedAt.toString(),
                                ward: filtergrievance[index].ward.toString(),
                                zone: filtergrievance[index].zone.toString(),
                                street: filtergrievance[index].street.toString(),
                                phone: filtergrievance[index].phone.toString(),
                                statusflow:
                                    filtergrievance[index].statusflow.toString(),
                                assign: filtergrievance[index]
                                    .assingusername
                                    .toString(),
                                grievid:
                                    filtergrievance[index].grievanceid.toString(),
                                pincode: filtergrievance[index].pincode.toString(),
                                complaindisc: filtergrievance[index]
                                    .complaintdetails
                                    .toString(),
                                complaint:
                                    filtergrievance[index].complaint.toString(),
                                lat: filtergrievance[index].lat.toString(),
                                lon: filtergrievance[index].lon.toString(),
                                icon: filtergrievance[index].escalationnotifyread ==
                                        'no'
                                    ? const Icon(
                                        Icons.chat,
                                        size: 30,
                                        color: Colors.red,
                                      )
                                    : const SizedBox(),
                                      onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  ReplyComplaint(
                      status: filtergrievance[index].status.toString(), 
                    username: filtergrievance[index].publicUsername.toString(), 
                    comtitile: filtergrievance[index].complainttypetitle.toString(), 
                    depart: filtergrievance[index].deptname.toString(), 
                    createddate: formattedDate, 
                    updatedate: formattedTime2, 
                    ward: filtergrievance[index].ward.toString(), 
                    zone: filtergrievance[index].zone.toString(), 
                    street: filtergrievance[index].street.toString(), 
                    phone: filtergrievance[index].phone.toString(), 
                    statusflow: filtergrievance[index].statusflow.toString(), 
                    assign: filtergrievance[index].assingusername.toString(), 
                    statusLabel:  getStatusColor(filtergrievance[index].status.toString()), 
                    status2:  filtergrievance[index].priority.toString(), 
                    statusLabel2: getStatusColor2(filtergrievance[index].priority.toString()), 
                    grievid: filtergrievance[index].grievanceid.toString(), 
                    pincode: filtergrievance[index].pincode.toString(),
                    complaindisc: filtergrievance[index].complaintdetails.toString(),
                    timeago:timeago ,createdtime: formattedTime, formateddate: formattedday,formateddate2: formattedday2,
                    complaint: filtergrievance[index].complaint.toString(),
                    lat: filtergrievance[index].lat.toString(),lon: filtergrievance[index].lon.toString(),
                    escalatenotify: filtergrievance[index].escalationnotifyread,
                    escalatednode: filtergrievance[index].escalationnotify,
              )));
                     },
                              );
                            });
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
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
      case 'Medium':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }
}
