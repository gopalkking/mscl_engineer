import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mscl_engineer/Controller/report_full_view_controller.dart';
class ReportsFullView extends StatefulWidget {
  final String grievid;
  final String status;
  final String comtitile;
  final String depart;
  final String complaindisc;
  final String pincode;
  final String ward;
  final String zone;
  final String street;
  final String phone;
  final String timeago;
 
  
  const ReportsFullView({super.key, required this.grievid, required this.status, required this.comtitile, required this.depart, required this.complaindisc, required this.pincode, required this.ward, required this.zone, required this.street, required this.phone, required this.timeago});

  @override
  State<ReportsFullView> createState() => _ReportsFullViewState();
}

class _ReportsFullViewState extends State<ReportsFullView> {
  ReportFullViewController reportFullViewController = Get.put(ReportFullViewController());

     final PageController _pageController = PageController();
@override
  void initState() {
      reportFullViewController.fetchGrievancesimage(widget.grievid);

    super.initState();
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
      final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
     backgroundColor: const Color.fromRGBO(244, 252, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
          style: IconButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 215, 229, 241),
            padding: const EdgeInsets.only(left: 10),
          ),
        ),
         title:  Text(
          widget.grievid,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                        widget.comtitile,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          softWrap: true,
                        ),
                      ),
                                        Text(
                   widget.timeago,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                    ],
                  ),

                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                       Text(
                        AppLocalizations.of(context)!.complainno,
                        style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 5,),
                        Text(
                        widget.grievid,
                        style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: screenWidth * 0.92,
                    padding: const EdgeInsets.all(20),
                    decoration:  BoxDecoration(color: Colors.white,boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 1.0)]),
                    child: Column(children: [
                             Row(children: [
                               Text(  AppLocalizations.of(context)!.phonenum1,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black87),),//12
                                const Spacer(),
                              SizedBox(width: 150, child: Text(widget.phone,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),softWrap: true,))//14
                            ],),
                            const SizedBox(height: 10,),
                             Row(children: [
                               Text(  AppLocalizations.of(context)!.address1,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black87),),
                              const Spacer(),
                                                         SizedBox(
                                  width: 150,
                                  child: Text(
                                    widget.street,
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w500),
                                        softWrap: true,
                                  ),
                                )
                            ],),
                            const SizedBox(height: 10,),
                             Row(children: [
                             Text(  AppLocalizations.of(context)!.pincode,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black87),),
                             const Spacer(),
                              SizedBox(width: 150, child: Text(widget.pincode,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),softWrap: true,))
                            ],),
                            const SizedBox(height: 10,),
                             Row(children: [
                              Text(  AppLocalizations.of(context)!.zone,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black87),),
                                  const Spacer(),
                              SizedBox(width: 150, child: Text(widget.zone,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,),softWrap: true,))
                            ],),
                            const SizedBox(height: 10,),
                             Row(children: [
                             Text(  AppLocalizations.of(context)!.ward,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black87),),
                                 const Spacer(),
                              SizedBox(width: 150, child: Text(widget.ward,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,),softWrap: true,))
                            ],),
                              const SizedBox(height: 10,),
                             Row(children: [
                             Text(  AppLocalizations.of(context)!.req,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black87),),
                                const Spacer(),
                              SizedBox(width: 150, child: Text(widget.comtitile,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),softWrap: true,))
                            ],),
                            const SizedBox(height: 10,),
                             Row(children: [
                              Text(  AppLocalizations.of(context)!.department1,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black87),),
                                  const Spacer(),
                              SizedBox(
                                width: 150,
                                child: Text(widget.depart,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
                                softWrap: true,))
                            ],),
                    ],),
                  ),
                   const SizedBox(height: 10,),
                                       Stack(
                      children: [
                        Obx(() {
                                        if (reportFullViewController.isLoading.value) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else if (reportFullViewController.imageBytesList.isNotEmpty) {
                                          return SizedBox(
                        height: 410.0,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: reportFullViewController.imageBytesList.length,
                          itemBuilder: (context, index) {
                            return OrientationBuilder(
                              builder: (context,orientation) {
                                return InstaImageViewer(
                                  child: Image.memory(
                                    reportFullViewController.imageBytesList[index],
                                      fit: BoxFit.contain,
                                                           width: orientation == Orientation.portrait
                                                            ? MediaQuery.of(context).size.width
                                                            : MediaQuery.of(context).size.height,
                                  ),
                                );
                              }
                            );
                          },
                        ),
                                          );
                                        } else {
                                          return 
                         Image.asset(
                        "assets/images/report.png",
                        fit: BoxFit.cover,
                        height: 410.0,
                        width: double.infinity,
                                          );
                                        
                                        }
                                      }),
                                        Obx(() {
                return reportFullViewController.imageBytesList.isNotEmpty
                    ? Positioned(
                        right: 0,
                        left: 10,
                        top: 380,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: reportFullViewController.imageBytesList.length,
                            effect: const ScrollingDotsEffect(
                              activeDotColor: Colors.blue,
                              dotColor: Colors.grey,
                              dotHeight: 8.0,
                              dotWidth: 8.0,
                              spacing: 8.0,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }),
              
                      ],
                    ),
     const SizedBox(height: 10,),
                  Container(
                      width: screenWidth * 0.92,
                    padding: const EdgeInsets.all(20),
                    decoration:  BoxDecoration(color: Colors.white,boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 1.0)]),
                    child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Text(AppLocalizations.of(context)!.complaintdetail, style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),),
                        Text(
                            widget.complaindisc,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 44,
                   // width: 104,
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)) ,
                   child:  Center(
                     child: Text(  AppLocalizations.of(context)!.status,style: const TextStyle(color: Colors.black87,fontSize: 19,fontWeight: FontWeight.w400),
                                       ),
                   ),),
                    Container(
                    height: 44,
                   // width: 104,
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    decoration: const BoxDecoration(color: Color.fromRGBO(0, 63, 91, 1), ) ,
                   child:  Center(
                     child: Text(widget.status,style: const TextStyle(color: Colors.white,fontSize: 19,fontWeight: FontWeight.w400),
                                       ),
                   ),),
                ],
              ),
            ),
            const SizedBox(height: 16.0), // Add some space at the bottom
          ],
        ),
      ),
    );
  }
}
