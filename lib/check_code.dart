import "package:flutter/material.dart";
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';




class PracticingPartOne extends StatefulWidget {
  @override
  _PracticingPartOneState createState() => _PracticingPartOneState();
}

class _PracticingPartOneState extends State<PracticingPartOne> {

  ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();

    itemScrollController = ItemScrollController();

   
     
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          itemScrollController.scrollTo(
            index: 10,
            duration: Duration(seconds: 2),
            curve: Curves.easeInOutCubic);

        },
      ),
      body:  ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionListener,
        itemCount: 12,
        itemBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(height: 50),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey
                )
              ),
            ],
          );
        },
      )
      
      
    );
    
  
  
  }
}