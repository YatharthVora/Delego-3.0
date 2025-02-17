import 'package:flutter/material.dart';
import 'package:delego/Pages/Schedule_Page/schedule_pagebody.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Code For Mumbai MUN
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(
//           iconTheme: IconThemeData(
//             color: Colors.white,
//           ),
//           backgroundColor: Colors.blue.shade900,
//           centerTitle: true,
//           title: Text(
//             "Schedule",
//             style: TextStyle(
//               color: Colors.white,
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           bottom: TabBar(
//             indicatorColor: Colors.white,
//             labelColor: Colors.white,
//             unselectedLabelColor: Colors.white70,
//             tabs: <Widget>[
//               Tab(
//                 text: "Day 1",
//               ),
//               Tab(
//                 text: "Day 2",
//               ),
//               Tab(
//                 text: "Day 3",
//               ),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: <Widget>[
//             Scaffold(
//               body: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   GradientAppBar(" November 8 , 2024"),
//                   ShedulePageBody(),
//                 ],
//               ),
//             ),
//             Scaffold(
//               body: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   GradientAppBar("November 9, 2024"),
//                   HomePageBodyDay2(),
//                 ],
//               ),
//             ),
//             Scaffold(
//               body: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   GradientAppBar("November 10, 2024"),
//                   HomePageBodyDay3(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//Code For Intar MUN
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
        title: Text(
          "Schedule",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GradientAppBar("February 23, 2025"),
          ShedulePageBody(),
        ],
      ),
    );
  }
}

class GradientAppBar extends StatelessWidget {
  final String title;
  final double barHeight = 66.0;

  GradientAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight + barHeight,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
              color: Colors.blue.shade800,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 24.0),
        ),
      ),
    );
  }
}


