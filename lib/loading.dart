import "package:flutter/material.dart";
import "package:flutter_spinkit/flutter_spinkit.dart";

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.lightBlueAccent,
        child: SpinKitWanderingCubes (
          size: 50.0,
          color: Colors.blue[900],
        ),
      ),
    );
  }
}
