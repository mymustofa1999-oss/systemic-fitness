import 'package:flutter/material.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/Constants.dart';


class CreateAccountDialog extends StatefulWidget {
  final Function clickListener;

  CreateAccountDialog({required this.clickListener});

  @override
  _CreateAccountDialog createState() => _CreateAccountDialog();
}

class _CreateAccountDialog extends State<CreateAccountDialog> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double radius = ConstantWidget.getScreenPercentSize(context,2);

    double height = ConstantWidget.getScreenPercentSize(context,50);
    double width = ConstantWidget.getWidthPercentSize(context,80);

    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0.0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
            height: height,
            width: width,
            padding: EdgeInsets.all(Constants.getDefaultHorizontalMargin(context)),
            decoration: getDefaultDecoration(
                radius: radius, bgColor: bgDarkWhite),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: ConstantWidget.getScreenPercentSize(context, 2),),

                Container(
                  height: ConstantWidget.getScreenPercentSize(context,17),
                  child: Image.asset(
                    Constants.assetsImagePath+'account.png',
                    ),
                ),

                SizedBox(height: ConstantWidget.getScreenPercentSize(context, 5),),

                ConstantWidget.getTextWidget(
                    'Account Created',
                    textColor,
                    TextAlign.center,
                    FontWeight.w700,
                    ConstantWidget.getScreenPercentSize(context, 2)),

                SizedBox(height: ConstantWidget.getScreenPercentSize(context, 1.5),),


                ConstantWidget.getTextWidget(
                    'Your account has been successfully created!',
                    textColor,
                    TextAlign.center,
                    FontWeight.w400,
                    ConstantWidget.getScreenPercentSize(context, 2)),

                SizedBox(height: ConstantWidget.getScreenPercentSize(context, 3
                ),),


                ConstantWidget.getButtonWidget(
                    context, 'Ok', blueButton, () {
                  widget.clickListener(context);
                  Navigator.of(context).pop();
                }),



              ],
            ),
          ),
        );
      },
    );
  }
}
