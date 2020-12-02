import "package:flutter/material.dart";
import 'package:flutter_svg/svg.dart';


class FormError extends StatelessWidget {
  final List<String> errors;

  FormError({ this.errors });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(errors.length, (index) {
        return formErrorText(errors[index]);
      }
    )
    );
  }

  Row formErrorText(String error) {
    return Row(
        children: [
          SvgPicture.asset(
            "assets/icons/error-24px.svg",
            color: Colors.red,
          ),
          SizedBox(width: 3),
          Text(
            error,
            style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.normal
              ),
          ),
        ],
      );
  }
}