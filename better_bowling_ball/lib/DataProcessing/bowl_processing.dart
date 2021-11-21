// have list of T, Ax, Ay, Az, Rx, Ry, Rz
//                  1   2   3   4   5  6
// have foot placement and pin hit

// step 1: get bowl start
// find pair where magnitude of acceleration is 9.8m/s

// have Start Time

// step 2: get end time
// look for pair after 2 seconds where magnitude of acceleration is 2X previous

// have End Time

// step 3: get Vx
// length/(t2-t1)

// have Vx

// step 4: get Speed
// select pair right before end. Find magnitude of rpm, multiply by circumference

// step 5: get Vy
// use pythagorean theorem

// step 6: get points

// n=1 to 65*2/3 / Vx*0.1
// start at pin hit, go back by Vx*0.1*n and across by Vy-
import 'dart:math';

import 'package:better_bowling_ball/db/bowling_database.dart';
import 'package:better_bowling_ball/model/model.point.dart';
import 'package:better_bowling_ball/model/model.bowl.dart';
class Processing {
  // static processData(List<List> data, double xFinish, double yFinish, int bowlId) {
  //   //1637027004646092,7081,6903,359,6497,5897,8387
  //   // 0                1     2    3  4     5    6
  //   double friction = 1;
  //   //finding start
  //   String start = "";
  //   for(int i = 0; i< data.length; i++) {
  //     var acc = sqrt(
  //         pow(data[i][1], 2)
  //             +
  //             pow(data[i][2], 2)
  //             +
  //             pow(data[i][3], 2)
  //     );
  //     if(acc > 9.7 && acc < 9.9) {
  //       start = data[i][0];
  //       break;
  //     }
  //   }
  //
  //   //remove values from before start
  //   data.forEach((element) {
  //     if(before(element[0], start)) {
  //       data.remove(element);
  //     }
  //   });
  //
  //   // find end time
  //   String end = "";
  //   int endIndex = 0;
  //   for(int i = 10; i< data.length; i++) {
  //     var acc1 = sqrt(
  //         pow(data[i][1], 2)
  //             +
  //             pow(data[i][2], 2)
  //             +
  //             pow(data[i][3], 2)
  //     );
  //     var acc2 = sqrt(
  //         pow(data[i-1][1], 2)
  //             +
  //             pow(data[i-1][2], 2)
  //             +
  //             pow(data[i-1][3], 2)
  //     );
  //     if(acc2 > acc1*2) {
  //       end = data[i][0];
  //       endIndex = i;
  //       break;
  //     }
  //   }
  //
  //   double Vx = 19.812/timeBetween(end, start);
  //
  //   double rps = sqrt(
  //         pow(data[endIndex - 2][4], 2)
  //           +
  //           pow(data[endIndex - 2][5], 2)
  //           +
  //           pow(data[endIndex - 2][6], 2)
  //   );
  //
  //
  //   double Speed = 0.6858 * rps / (2 * pi);
  //
  //   double Vy = sqrt(pow(Speed, 2) - pow(Vx, 2));
  //
  //
  //
  //   for(int i = 0; yFinish > 43; i++) {
  //     BowlingDatabase.instance.createPoint(Point(bowlId: bowlId,
  //         sequenceId: 0,
  //         xPos: xFinish,
  //         yPos: yFinish - 0.1 * Vy * i,
  //         time: end - 0.1 * i));
  //
  //     xFinish = xFinish - (0.1 * Vx - data[2][5] * friction * i);
  //   }
  //
  // }

  //implement
  static  bool before(String date1, String date2) {
    return true;
  }

  //implement
  static double timeBetween(int date1, int date2) {
    return (date1 - date2)/1000000.0;
  }

  static processData2(List<List> data, double xStart, double xFinish, double yFinish, int bowlId) async {

    // find start of throw
    int startTime = 0;
    for(int i = 0; i< data.length; i++) {
      var acc = sqrt(
          pow(data[i][1], 2)
              +
              pow(data[i][2], 2)
              +
              pow(data[i][3], 2)
      );
      if(acc > 9.7 && acc < 9.9) {
        startTime = data[i][0];
        break;
      }
    }

    //remove readings from before throw
    data.removeWhere((element) => element[0] < startTime);

    //TODO add cutoff if necessary
    double cutoff = 0;
    // find end time
    int endTime = 3637028005646092;
    for(int i = 15; i< data.length; i++) {
      var acc1 = sqrt(
          pow(data[i][1], 2)
              +
              pow(data[i][2], 2)
              +
              pow(data[i][3], 2)
      );
      var acc2 = sqrt(
          pow(data[i-1][1], 2)
              +
              pow(data[i-1][2], 2)
              +
              pow(data[i-1][3], 2)
      );
      if(acc2 > acc1*2 && acc2 > cutoff) {
        endTime = data[i][0];
        break;
      }
    }

    double Vx = 19.812/timeBetween(endTime, startTime);
    
    double rps = sqrt(
        pow(data[data.length - 3][4], 2)
            +
            pow(data[data.length - 3][5], 2)
            +
            pow(data[data.length - 3][6], 2)
    );


    double Speed = 0.6858 * rps / (2 * pi);

    double Vy = sqrt(pow(Speed, 2) - pow(Vx, 2));

    int endIndex = data.length;

    List<List<double>> points = [[0,0]];

    //translate 1.225 before hook
    for(int i = 1; i < 41; i++) {
      points.add([points[i-1][0]+0.0299,i*1.0]);
    }

    // hook pixel points
    List<List<int>> pixelPoints = [
      [81, 135],
      [82, 130],
      [82, 125],
      [83, 120],
      [82, 115],
      [82, 110],
      [82, 105],
      [82, 100],
      [82, 95],
      [81, 90],
      [81, 85],
      [81, 80],
      [80, 75],
      [79, 70],
      [78, 65],
      [77, 60],
      [76, 55],
      [74, 50],
      [73, 45],
      [71, 40],
      [69, 35],
      [68, 30],
      [65, 25],
      [63, 20],
      [61, 15],
      [59, 10],
      [57, 5],
      [55, 0]
    ];

    for(int i = 0; i < pixelPoints.length; i++) {
      points.add(
        [
          pixelPoints[i][0]/21.77 - 2.25,
          65 - pixelPoints[i][0]/5.615,
        ]
      );
    }

    double curveFactor = 0.01*data[5][4]/Vx;
    
    //linear transformation 1
    for(int i = 0; i < points.length; i++) {
      points[i] = [points[i][0]*curveFactor, points[i][1]];
    }

    //linear transformation 2
    double traversalDistance = (xFinish - xStart) / points.length;
    for(int i = 0; i < points.length; i++) {
      points[i] = [points[i][0] + (i * traversalDistance), points[i][1]];
    }

    //
    // int? id,
    // int? bowlId,
    // int? sequenceId,
    // double? xPos,
    // double? yPos,
    // DateTime? time,
    for(int i = 0; i < points.length; i++) {
      BowlingDatabase.instance.createPoint(Point(
        bowlId: bowlId,
        sequenceId: i,
        xPos: points[i][0],
        yPos: points[i][1],
        time: DateTime.fromMicrosecondsSinceEpoch(startTime + (i*0.1*1000000).round()),
      ));
    }

    var oldBowl = await BowlingDatabase.instance.readBowl(bowlId);

    BowlingDatabase.instance.update(Bowl(
        speed: Speed,
        rpm: rps,
        xRotation: points[3][4],
        yRotation: points[3][5],
        zRotation: points[3][5],
        footPlacement: oldBowl.footPlacement,
        pinHit: oldBowl.pinHit,
        timestamp: oldBowl.timestamp)


    )



  }


}