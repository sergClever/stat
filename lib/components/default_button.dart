import "package:flutter/material.dart";


class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key key, this.press, this.text,
  }) : super(key: key);

  final Function press;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: RaisedButton(
        color: Colors.blue[500],
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)),
        onPressed: press,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          ),
          ),
        ),
    );
  }
}

