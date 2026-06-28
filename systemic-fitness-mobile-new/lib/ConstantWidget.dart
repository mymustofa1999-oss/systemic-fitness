import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workout/Constants.dart';

import 'ColorCategory.dart';
getNoData(BuildContext context) {
  return Container(
    // color: mainBgColor,
    margin: EdgeInsets.symmetric(vertical: ConstantWidget.getScreenPercentSize(context,5)),
      child: Center(
        child: Text(
         'No Data Found',
          style: TextStyle(
              color: Colors.black87,
              fontFamily: Constants.fontsFamily,
              fontWeight: FontWeight.bold),
        ),
      ));
}


getDefaultNextButton(BuildContext context,{Function? function,IconData? icon}){
  double height = ConstantWidget.getScreenPercentSize(context, 7);

  double subHeight = ConstantWidget.getPercentSize(height, 35);
  return      InkWell(
    onTap: (){

      if(function!=null){
        function();
      }

    },
    child: Container(
      height: subHeight,
      width: subHeight,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black,width: ConstantWidget.getPercentSize(subHeight,7)),
          borderRadius: BorderRadius.all(Radius.circular(ConstantWidget.getPercentSize(subHeight, 42)))
      ),
      child: Center(
        child: Icon(
          (icon!=null)?icon: Icons.close,
          color: Colors.black,
          size: ConstantWidget.getPercentSize(subHeight,70),
        ),
      ),
    ),
  );
}

getDefaultButton(BuildContext context,{Function? function}){
  double height = ConstantWidget.getScreenPercentSize(context, 7);

  double subHeight = ConstantWidget.getPercentSize(height, 35);
  return      InkWell(
    onTap: (){

      if(function!=null){
        function();
      }

    },
    child: Container(
      height: subHeight,
      width: subHeight,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black,width: ConstantWidget.getPercentSize(subHeight,7)),
          borderRadius: BorderRadius.all(Radius.circular(ConstantWidget.getPercentSize(subHeight, 42)))
      ),
      child: Center(
        // child: SvgPicture.asset(
        //   icon==null?  Constants.assetsImagePath + 'Arrow _Left.svg',
        //   height: ConstantWidget.getScreenPercentSize(
        //       context, 3),
        // ),
        child: Icon(
          Icons.close,
          color: Colors.black,
          size: ConstantWidget.getPercentSize(subHeight,70),
        ),
      ),
    ),
  );
}


getDefaultBackButton(BuildContext context,{Function? function}){
  double height = ConstantWidget.getScreenPercentSize(context, 7);

  double subHeight = ConstantWidget.getPercentSize(height, 44);
  return      Container(
    child: InkWell(
      onTap: (){

        if(function!=null){
          function();
        }

      },

      child: SvgPicture.asset(
      Constants.assetsImagePath + 'Arrow - Left.svg',
        height: subHeight,
        width: subHeight,
        fit: BoxFit.fitWidth,
      ),
    ),
  );
}
getDefaultButtonWithAsset(BuildContext context,{Function? function,String? icon}){
  double height = ConstantWidget.getScreenPercentSize(context, 7);

  double subHeight = ConstantWidget.getPercentSize(height, 35);
  return      InkWell(
    onTap: (){

      if(function!=null){
        function();
      }

    },
    child: Container(
      height: subHeight,
      width: subHeight,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black,width: ConstantWidget.getPercentSize(subHeight,7)),
          borderRadius: BorderRadius.all(Radius.circular(ConstantWidget.getPercentSize(subHeight, 42)))
      ),
      child: Center(
        child: Image.asset(
          (icon!=null)?Constants.assetsImagePath+icon: Constants.assetsImagePath+'Icons.close',
          color: Colors.black,
          height: ConstantWidget.getPercentSize(subHeight,60  ),
          width: ConstantWidget.getPercentSize(subHeight,60),
        ),
      ),
    ),
  );
}



class ConstantWidget {



  static Widget textFieldProfileWidget(BuildContext context, String s,
      var icon, bool isEnabled, TextEditingController textEditingController,Function function) {
    double height = ConstantWidget.getScreenPercentSize(context, 7);

    double radius = ConstantWidget.getPercentSize(height, 20);
    double fontSize = ConstantWidget.getPercentSize(height, 25);

    return getShadowWidget(verticalMargin: ConstantWidget.getScreenPercentSize(context, 1.2),widget: Container(
      height: height,


      alignment: Alignment.centerLeft,
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.all(
      //     Radius.circular(radius),
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black12,
      //       blurRadius: 8.0,
      //       offset: Offset(0, 4),
      //     ),
      //   ],
      // ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: 1,
              controller: textEditingController,
              enabled: isEnabled,
              style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: isEnabled?accentColor:Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize),
              decoration: InputDecoration(
                // contentPadding: EdgeInsets.only(
                //     left: ConstantWidget.getWidthPercentSize(context, 1.5)),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: s,
                  // icon:  Padding(
                  //   padding: const EdgeInsets.only(left:8.0),
                  //   child: Icon(Icons.account_circle_sharp),
                  // ),

                  icon: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(icon, color: isEnabled?accentColor:Colors.grey,),
                  ),
                  // icon: getIcon(icon, ),

                  // prefixIcon: Icon(Icons.account_circle_sharp),
                  hintStyle: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize)),
            ),
          )
        ],
      ),
    ),

    radius: radius,);
  }




  static Widget editAddressWidget(BuildContext context, String s,
      var icon, bool isEnabled, TextEditingController textEditingController) {
    double height = ConstantWidget.getScreenPercentSize(context, 7);

    double radius = ConstantWidget.getPercentSize(height, 20);
    double fontSize = ConstantWidget.getPercentSize(height, 25);

    return getShadowWidget(widget: Container(
      // height: height,


      alignment: Alignment.centerLeft,
      child:



      TextField(
        controller: textEditingController,
        enabled: isEnabled,
        maxLines: 5,
        keyboardType: TextInputType.multiline,

        style: TextStyle(
            fontFamily: Constants.fontsFamily,
            color: isEnabled?accentColor:Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: fontSize),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(
                ConstantWidget.getWidthPercentSize(context, 2.5)),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: s,



            hintStyle: TextStyle(
                fontFamily: Constants.fontsFamily,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: fontSize)),
      ),
      // ),
    ),
    radius: radius);
  }

  static Widget editProfileWidget(BuildContext context, String s,
      var icon, bool isEnabled, TextEditingController textEditingController,Function function) {
    double height = ConstantWidget.getScreenPercentSize(context, 7);

    double radius = ConstantWidget.getPercentSize(height, 20);
    double fontSize = ConstantWidget.getPercentSize(height, 25);

    return getShadowWidget(
      radius: radius,
      verticalMargin: ConstantWidget.getScreenPercentSize(context, 1.2),
      widget: InkWell(

        onTap: (){
          if(isEnabled){
            function();
          }
        },
        child: Container(
          height: height,


          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(
              left: ConstantWidget.getWidthPercentSize(context, 2.5)),


          child: TextField(
            maxLines: 1,
            controller: textEditingController,
            enabled: false,
            style: TextStyle(
                fontFamily: Constants.fontsFamily,
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: fontSize),
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.only(
              //     left: ConstantWidget.getWidthPercentSize(context, 1.5)),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: s,

                suffixIcon: getIcon(icon),
                hintStyle: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize)),
          ),
        ),
      ),
    );
  }

  static getIcon(var icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Icon(icon),
    );
  }

  static double getPercentSize(double total, double percent) {
    return (total * percent) / 100;
  }
  static Widget getAddressWidget(BuildContext context, String s,
      TextEditingController textEditingController,double margin) {
    double height = ConstantWidget.getScreenPercentSize(context, 8.5);

    double radius = ConstantWidget.getPercentSize(height, 15);
    double fontSize = ConstantWidget.getPercentSize(height, 23);
    double padding= ConstantWidget.getScreenPercentSize(context, 1.2);

    // return getShadowWidget(widget: Container(
    //   padding: EdgeInsets.only(
    //       top: ConstantWidget.getScreenPercentSize(context,1)),
    //
    //
    //
    //
    //
    //   child: TextField(
    //     maxLines: 5,
    //     controller: textEditingController,
    //     style: TextStyle(
    //         fontFamily: Constants.fontsFamily,
    //         color: Colors.black,
    //         fontWeight: FontWeight.w400,
    //         fontSize: fontSize),
    //     decoration: InputDecoration(
    //         contentPadding: EdgeInsets.only(
    //             left: ConstantWidget.getWidthPercentSize(context, 2)),
    //         border: InputBorder.none,
    //         focusedBorder: InputBorder.none,
    //         enabledBorder: InputBorder.none,
    //         errorBorder: InputBorder.none,
    //         disabledBorder: InputBorder.none,
    //         hintText: s,
    //         hintStyle: TextStyle(
    //             fontFamily: Constants.fontsFamily,
    //             color: Colors.grey,
    //             fontWeight: FontWeight.w400,
    //             fontSize: fontSize)),
    //   ),
    // ), radius: radius,horizontalMargin: margin
    // );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1),
      padding: EdgeInsets.all( padding),
      decoration: getDefaultDecoration(borderColor: borderColor,radius:  radius),

      child: Container(
        // padding: EdgeInsets.only(
        //     top: ConstantWidget.getScreenPercentSize(context,1)),





        child: TextField(
          maxLines: 5,
          controller: textEditingController,
          style: TextStyle(
              fontFamily: Constants.fontsFamily,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: fontSize),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: s,
              hintStyle: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: subTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize)),
        ),
      ),
    );
  }



  static Widget getIntroBorderButtonWidget(
      BuildContext context, String s, Function function) {
    double height = ConstantWidget.getScreenPercentSize(context, 7);
    double radius = ConstantWidget.getPercentSize(height, 20);
    double fontSize = ConstantWidget.getPercentSize(height, 30);

    return InkWell(
      child: Container(
        height: height,
        margin: EdgeInsets.symmetric(
            vertical: ConstantWidget.getScreenPercentSize(context, 1.2),
            horizontal: ConstantWidget.getScreenPercentSize(context, 1.2)),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: accentColor),
          borderRadius: BorderRadius.all(
            Radius.circular(radius),
          ),
        ),
        child: Center(
            child: getDefaultTextWidget(
                s, TextAlign.center, FontWeight.bold, fontSize, Colors.black)),
      ),
      onTap: () {
        function();
      },
    );
  }

  static Widget getIntroButtonWidget(
      BuildContext context, String s, var color, Function function) {
    double height = ConstantWidget.getScreenPercentSize(context, 7);
    double radius = ConstantWidget.getPercentSize(height, 20);
    double fontSize = ConstantWidget.getPercentSize(height, 30);

    return InkWell(
      child: Container(
        height: height,
        margin: EdgeInsets.symmetric(
            vertical: ConstantWidget.getScreenPercentSize(context, 1.2),
           ),

        decoration: getDefaultDecoration(radius: radius,bgColor:  color,),


        // decoration: BoxDecoration(
        //     color: color,
        //     borderRadius: BorderRadius.all(
        //       Radius.circular(radius),
        //     ),
        //     boxShadow: [getShadow()]),
        child: Center(
            child: getDefaultTextWidget(
                s, TextAlign.center, FontWeight.bold, fontSize, Colors.white)),
      ),
      onTap: () {
        function();
      },
    );
  }

  static Widget getCustomTextWidget(String string, Color color, double size,
      FontWeight fontWeight, TextAlign align, int maxLine) {
    return Text(string,
        textAlign: align,
        maxLines: maxLine,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: fontWeight,
            fontSize: size,
            fontFamily: Constants.fontsFamily,
            color: color));
  }
  static OutlineInputBorder getOutlineBorder(var color, var width, var radius) {
    return new OutlineInputBorder(
        borderSide: BorderSide(color: color, width: width),
        borderRadius: BorderRadius.all(Radius.circular(radius)));
  }


  static Widget getHorizonSpace(double space) {
    return SizedBox(
      width: space,
    );
  }
  static Widget getCustomTextWithUnderLine(String text, TextAlign textAlign,
      Color color, FontWeight fontWeight, double fontSize) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
          decoration: TextDecoration.underline,
          color: color,
          fontSize: fontSize,
          fontFamily: Constants.fontsFamily,
          fontWeight: fontWeight),
    );
  }
  static Widget getCustomTextWithFontFamilyWidget(String string, Color color,
      double size, FontWeight fontWeight, TextAlign align, int maxLine) {
    return Text(string,
        textAlign: align,
        maxLines: maxLine,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontWeight: fontWeight,
            fontSize: size,
            fontFamily: Constants.fontsFamily,
            color: color));
  }

  static Widget getButtonWithoutSpaceWidget(
      BuildContext context, String s, var color, Function function) {
    double height = getScreenPercentSize(context, 7);
    double radius = getPercentSize(height, 20);
    double fontSize = getPercentSize(height, 30);

    return InkWell(
      child: Material(
        color: Colors.transparent,
        shadowColor: primaryColor.withOpacity(0.3),
        elevation: getPercentSize(height, 45),
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(getPercentSize(radius, 85)))),
        child: Container(
          height: height,
          margin: EdgeInsets.only(
            bottom: getScreenPercentSize(context, 1.5),
          ),
          decoration: ShapeDecoration(
            color: color,


            shape: SmoothRectangleBorder(
              side: BorderSide(color: subTextColor, width: 0.3),
              borderRadius: SmoothBorderRadius(
                cornerRadius: radius,
                cornerSmoothing: 0.8,
              ),
            ),
          ),
          child: Center(
              child: getDefaultTextWidget(
                  s, TextAlign.center, FontWeight.w500, fontSize, Colors.white)),
        ),
      ),
      onTap: () {
        function();
      },
    );
  }

  static Widget  getLoginAppBar(BuildContext context,{bool? isMargin,Function? function,String? title,bool? isInfo,Function? infoFunction}) {
    double height = getScreenPercentSize(context, 7);
    return Container(
      height: height,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isMargin!=null?0:Constants.getDefaultHorizontalMargin(context)),
      child: Stack(

        children: [



          Center(
            child: ConstantWidget.getTextWidget((title==null)?'':title, textColor,
                TextAlign.center,FontWeight.bold, ConstantWidget.getPercentSize(height, 30)),
          ),


          Align(
            alignment: Alignment.centerLeft,
            child: getDefaultBackButton(context,function: function),
          ),
          Align(
              alignment: Alignment.centerRight,
              child:  isInfo==null ? Container():InkWell(onTap:(){
                if(infoFunction!=null){
                  infoFunction();
                }
              },child: Icon(Icons.info,color: textColor
                  ,size:
              ConstantWidget.getScreenPercentSize(context, 3)))
          ),


        ],
      ),
    );
  }


  static  Widget getDefaultTextFiledWidget(BuildContext context, String s,
      TextEditingController textEditingController,{bool? isEnabled}) {
    double height = getDefaultButtonSize(context);

    double radius = getPercentSize(height, 20);
    double fontSize = getPercentSize(height, 27);


    Color color = borderColor;


    return StatefulBuilder(
      builder: (context, setState) {
        // myFocusNode.addListener((){
        //
        //   print("focus---${myFocusNode.hasFocus}---$s");
        //
        //
        //   setState((){
        //     if(myFocusNode.hasFocus){
        //       color=primaryColor;
        //     }else{
        //       color = borderColor;
        //     }
        //   });
        //
        // });
        return Container(
          height: height,
          margin:
          EdgeInsets.symmetric(vertical: getScreenPercentSize(context, 1.2)),
          alignment: Alignment.centerLeft,

          decoration: getDefaultDecoration(radius: radius,borderColor:  color),



          child: Focus(
            onFocusChange: (hasFocus) {

            },
            child: TextFormField(
              // focusNode: myFocusNode,
              maxLines: 1,
              enabled: (isEnabled!=null)?isEnabled:true,
              controller: textEditingController,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize),
              decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.only(left: getWidthPercentSize(context, 4)),
                  border: OutlineInputBorder(),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: s,

                  isDense: true,
                  hintStyle: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      color: subTextColor,
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize)),
            ),
          ),
        );
      },
    );
  }


  // static Widget getDefaultTextFiledWidget(BuildContext context, String s,
  //     TextEditingController textEditingController) {
  //   double height = ConstantWidget.getScreenPercentSize(context, 8.5);
  //
  //   double radius = ConstantWidget.getPercentSize(height, 20);
  //   double fontSize = ConstantWidget.getPercentSize(height, 25);
  //
  //   return Container(
  //     height: height,
  //     margin: EdgeInsets.symmetric(
  //         vertical: ConstantWidget.getScreenPercentSize(context, 1.2)),
  //     alignment: Alignment.centerLeft,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.all(
  //         Radius.circular(radius),
  //       ),
  //     ),
  //     child: TextField(
  //       maxLines: 1,
  //       controller: textEditingController,
  //       style: TextStyle(
  //           fontFamily: Constants.fontsFamily,
  //           color: Colors.black,
  //           fontWeight: FontWeight.w400,
  //           fontSize: fontSize),
  //       decoration: InputDecoration(
  //           contentPadding: EdgeInsets.only(
  //               left: ConstantWidget.getWidthPercentSize(context, 2)),
  //           border: InputBorder.none,
  //           focusedBorder: InputBorder.none,
  //           enabledBorder: InputBorder.none,
  //           errorBorder: InputBorder.none,
  //           disabledBorder: InputBorder.none,
  //           hintText: s,
  //           hintStyle: TextStyle(
  //               fontFamily: Constants.fontsFamily,
  //               color: Colors.grey,
  //               fontWeight: FontWeight.w400,
  //               fontSize: fontSize)),
  //     ),
  //   );
  // }

  static Widget getRoundCornerButtonWithoutIcon(String texts, Color color,
      Color textColor, double btnRadius, Function function) {
    return InkWell(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(btnRadius),
              shape: BoxShape.rectangle,
              color: color,
            ),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: Center(
              child: getCustomText(
                  texts, textColor, 1, TextAlign.center, FontWeight.w500, 18),
            ),
          )
        ],
      ),
      onTap: () {
        function();
      },
    );
  }


  static getDefaultButtonSize(BuildContext context){
    return getScreenPercentSize(context, 6.5);
  }

  // static Widget getButtonWidget1(
  //     BuildContext context, String s, var color, Function function) {
  //   double height = getDefaultButtonSize(context);
  //   double radius = ConstantWidget.getPercentSize(height, 20);
  //   double fontSize = ConstantWidget.getPercentSize(height, 30);
  //
  //   return InkWell(
  //     child: Container(
  //       height: height,
  //       margin: EdgeInsets.symmetric(
  //           vertical: ConstantWidget.getScreenPercentSize(context, 1.2)),
  //       decoration: BoxDecoration(
  //         color: color,
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(radius),
  //         ),
  //       ),
  //       child: Center(
  //           child: getDefaultTextWidget(
  //               s, TextAlign.center, FontWeight.w500, fontSize, Colors.black)),
  //     ),
  //     onTap: () {
  //       function();
  //     },
  //   );
  // }

  static Widget getPasswordTextFiled(BuildContext context, String s,
      TextEditingController textEditingController) {
    return _PasswordTextField(
      hint: s,
      controller: textEditingController,
    );
  }


  // static Widget getPasswordTextFiled(BuildContext context, String s,
  //     TextEditingController textEditingController) {
  //   double height = ConstantWidget.getScreenPercentSize(context, 8.5);
  //   double radius = ConstantWidget.getPercentSize(height, 20);
  //   double fontSize = ConstantWidget.getPercentSize(height, 25);
  //
  //   return Container(
  //       height: height,
  //       alignment: Alignment.centerLeft,
  //       margin: EdgeInsets.symmetric(
  //           vertical: ConstantWidget.getScreenPercentSize(context, 1.2)),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(radius),
  //         ),
  //       ),
  //       child: TextField(
  //         maxLines: 1,
  //         obscureText: true,
  //         controller: textEditingController,
  //         style: TextStyle(
  //             fontFamily: Constants.fontsFamily,
  //             color: Colors.black,
  //             fontWeight: FontWeight.w400,
  //             fontSize: fontSize),
  //         decoration: InputDecoration(
  //             contentPadding: EdgeInsets.only(
  //                 left: ConstantWidget.getWidthPercentSize(context, 2)),
  //             border: InputBorder.none,
  //             focusedBorder: InputBorder.none,
  //             enabledBorder: InputBorder.none,
  //             errorBorder: InputBorder.none,
  //             disabledBorder: InputBorder.none,
  //             hintText: s,
  //             hintStyle: TextStyle(
  //                 fontFamily: Constants.fontsFamily,
  //                 color: Colors.grey,
  //                 fontWeight: FontWeight.w400,
  //                 fontSize: fontSize)),
  //       ));
  // }

  static Widget getButtonWidget(
      BuildContext context, String s, var color, Function function) {
    double height = ConstantWidget.getDefaultButtonSize(context);
    double radius = ConstantWidget.getPercentSize(height, 20);
    double fontSize = ConstantWidget.getPercentSize(height, 30);

    return InkWell(
      child: Container(
        height: height,
        margin: EdgeInsets.symmetric(
            vertical: ConstantWidget.getScreenPercentSize(context, 1.2)),
        // decoration: BoxDecoration(
        //   color: color,
        //   borderRadius: BorderRadius.all(
        //     Radius.circular(radius),
        //   ),
        // ),

        decoration: getDefaultDecoration(radius: radius,bgColor:  accentColor),


        child: Center(
            child: getDefaultTextWidget(
                s, TextAlign.center, FontWeight.bold, fontSize, Colors.white)),
      ),
      onTap: () {
        function();
      },
    );
  }

  static Widget getBorderButtonWidget(
      BuildContext context, String s, Function function,{Color? borderColor,double? btnHeight}) {
    double height = btnHeight==null?ConstantWidget.getDefaultButtonSize(context):btnHeight;
    double radius = ConstantWidget.getPercentSize(height, 20);
    double fontSize = ConstantWidget.getPercentSize(height, 30);

    return InkWell(
      child: Container(
        height: height,
        margin: EdgeInsets.symmetric(
            vertical: ConstantWidget.getScreenPercentSize(context, 1.2)),
        // decoration: BoxDecoration(
        //   color: color,
        //   borderRadius: BorderRadius.all(
        //     Radius.circular(radius),
        //   ),
        // ),

        decoration: getDefaultDecoration(radius: radius,borderColor:borderColor==null? accentColor:borderColor),


        child: Center(
            child: getDefaultTextWidget(
                s, TextAlign.center, FontWeight.bold, fontSize, borderColor==null?accentColor:borderColor)),
      ),
      onTap: () {
        function();
      },
    );
  }

  static double largeTextSize = 28;

  static double getMarginTop(BuildContext context) {
    // double height = getScreenPercentSize(context, 20);
    double height = getScreenPercentSize(context, 23);

    return (height / 2) + getScreenPercentSize(context, 2.5);
  }

  static double getBlankTop(BuildContext context) {
    double height = getScreenPercentSize(context, 20);

    return getPercentSize(height, 85);
  }

  static Widget getCustomTextWithoutAlign(
      String text, Color color, FontWeight fontWeight, double fontSize) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: Constants.fontsFamily,
          decoration: TextDecoration.none,
          fontWeight: fontWeight),
    );
  }

  static double getScreenPercentSize(BuildContext context, double percent) {
    return (MediaQuery.of(context).size.height * percent) / 100;
  }

  static double getWidthPercentSize(BuildContext context, double percent) {
    return (MediaQuery.of(context).size.width * percent) / 100;
  }

  static Widget getSpace(double space) {
    return SizedBox(
      height: space,
    );
  }

  static Widget getTextWidgetWithFontWithMaxLine1(
      String text,
      Color color,
      TextAlign textAlign,
      FontWeight fontWeight,
      double textSizes,
      String font) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: textSizes,
          color: color,
          fontFamily: font,
          letterSpacing: 1,
          fontWeight: fontWeight),
      textAlign: textAlign,
    );
  }


  static Widget getShadowWidget({required Widget widget,double? margin,double? verticalMargin ,double? horizontalMargin ,double? radius,double? topPadding,double? leftPadding,double? rightPadding,double? bottomPadding,Color? color,bool? isShadow}){
    return   Container(
      padding: EdgeInsets.symmetric(horizontal: (margin==null)?0:margin),
      margin: EdgeInsets.symmetric(
          vertical: (verticalMargin==null)?0:verticalMargin,
          horizontal: (horizontalMargin==null)?0:horizontalMargin
      ),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow:isShadow==null? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ]:[],
        ),
        child: Container(
          decoration: getDefaultDecoration(
              bgColor: (color == null)?Colors.white:color,
              radius:  (radius==null)?0:radius),

          padding: EdgeInsets.only(
            top: (topPadding==null)?0:topPadding,
            bottom: (bottomPadding==null)?0:bottomPadding,
            right: (rightPadding==null)?0:rightPadding,
          left: (leftPadding==null)?0:leftPadding,),
          child: widget,
        ),
      ),
    );
  }
  static Widget getCustomText(String text, Color color, int maxLine,
      TextAlign textAlign, FontWeight fontWeight, double textSizes) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: textSizes,
          color: color,
          fontFamily: Constants.fontsFamily,
          fontWeight: fontWeight),
      maxLines: maxLine,
      textAlign: textAlign,
    );
  }

  static Widget getCustomTextFont(
      String text,
      Color color,
      int maxLine,
      TextAlign textAlign,
      FontWeight fontWeight,
      double textSizes,
      String font) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: textSizes,
          color: color,
          fontFamily: font,
          height: 1.1,
          fontWeight: fontWeight),
      maxLines: maxLine,
      textAlign: textAlign,
    );
  }


  static Widget getCustomTextFontWithSpace(
      String text,
      Color color,
      int maxLine,
      TextAlign textAlign,
      FontWeight fontWeight,
      double textSizes,
      String font) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: textSizes,
          color: color,
          fontFamily: font,
          height: 1.3,
          fontWeight: fontWeight),
      maxLines: maxLine,
      textAlign: textAlign,
    );
  }

  static Widget getTextWidgetWithSpacing(String text, Color color,
      TextAlign textAlign, FontWeight fontWeight, double textSizes) {
    return Text(
      text,
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: textSizes,
          color: color,
          height: 1.5,
          fontFamily: Constants.fontsFamily,
          fontWeight: fontWeight),
      textAlign: textAlign,
    );
  }

  static Widget getTextWidget(String text, Color color, TextAlign textAlign,
      FontWeight fontWeight, double textSizes) {
    return Text(
      text,
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: textSizes,
          color: color,
            fontFamily: Constants.fontsFamily,
          fontWeight: fontWeight),
      textAlign: textAlign,
    );
  }

  static Widget getTextWidgetWithFont(
      String text,
      Color color,
      TextAlign textAlign,
      FontWeight fontWeight,
      double textSizes,
      String font) {
    return Text(
      text,
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: textSizes,
          color: color,
          fontFamily: font,
          letterSpacing: 1,
          fontWeight: fontWeight),
      textAlign: textAlign,
    );
  }

  static Widget getTextWidgetWithFontWithMaxLine(
      String text,
      Color color,
      TextAlign textAlign,
      FontWeight fontWeight,
      double textSizes,
      String font,
      int maxLine) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLine,
      style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: textSizes,
          color: color,
          fontFamily: font,
          letterSpacing: 1,
          fontWeight: fontWeight),
      textAlign: textAlign,
    );
  }

  static Widget getDefaultTextWidget(String s, TextAlign textAlign,
      FontWeight fontWeight, double fontSize, var color) {
    return Text(
      s,
      textAlign: textAlign,
      style: TextStyle(
          fontFamily: Constants.fontsFamily,
          fontWeight: fontWeight,
          fontSize: fontSize,
          color: color),
    );
  }
}

TextStyle homeWhiteRegularTextStyle = TextStyle(
  fontFamily: Constants.fontsFamily,
  fontSize: 17,
  color: Colors.white,
);



getDefaultDecoration({double? radius,Color? bgColor,Color? borderColor}){
  return ShapeDecoration(
    color:(bgColor==null)? Colors.transparent:bgColor,
    shape: SmoothRectangleBorder(
      side: BorderSide(
          color: (borderColor==null)? Colors.transparent:borderColor, width: (borderColor==null)?0:1

      ),

      borderRadius: SmoothBorderRadius(
        cornerRadius: (radius==null)?0:radius,
        cornerSmoothing: 0.8,

      ),
    ),
  );
}

getDecorationWithSide({double? radius,Color? bgColor,Color?
borderColor,bool? isTopRight,bool? isTopLeft,bool? isBottomRight,bool? isBottomLeft}){
  return ShapeDecoration(
    color:(bgColor==null)? Colors.transparent:bgColor,
    shape: SmoothRectangleBorder(
      side: BorderSide(
          color: (borderColor==null)? Colors.transparent:borderColor, width: (borderColor==null)?0:1

      ),
      borderRadius: SmoothBorderRadius.only(

        bottomRight: SmoothRadius(
          cornerRadius: (isBottomRight==null)? 0:radius!,
          cornerSmoothing: 1,
        ),
        bottomLeft: SmoothRadius(
          cornerRadius:  (isBottomLeft==null)? 0:radius!,
          cornerSmoothing: 1,
        ),
        topLeft: SmoothRadius(
          cornerRadius:  (isTopLeft==null)? 0:radius!,
          cornerSmoothing: 1,
        ),

        topRight: SmoothRadius(
          cornerRadius:  (isTopRight==null)? 0:radius!,
          cornerSmoothing: 1,
        ),


      ),
    ),
  );
}

getColorStatusBar(Color? color){
 return AppBar(
    backgroundColor: color,
    toolbarHeight: 0,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle( systemNavigationBarColor: color,statusBarColor: color),

  );
}
setStatusBarColor(Color color){
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: color
  ));
}

getShadow() {
  return BoxShadow(
    color: Colors.black12,
    blurRadius: 3.0,
    offset: Offset(0, 4),
  );
}
getNoneAppBar(BuildContext context, {Color? color, bool? isFullScreen}) {
  if (color == null) {
    color = bgDarkWhite;
  }
  var overlayStyle = SystemUiOverlayStyle.light; // 1

  if (overlayStyle == SystemUiOverlayStyle.light) {
    overlayStyle = SystemUiOverlayStyle.dark;
  } else {
    overlayStyle = SystemUiOverlayStyle.light;
  }

  if (color == bgDarkWhite) {

      overlayStyle = SystemUiOverlayStyle.dark;

  }

  return AppBar(
    toolbarHeight: 0,
    elevation: 0,
    primary: false,
    backgroundColor: color,
    systemOverlayStyle: overlayStyle.copyWith(
      statusBarColor: color,
    ),
  );
}

class _PasswordTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;

  const _PasswordTextField({
    required this.hint,
    required this.controller,
  });

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _obscure = true;
  Color _borderColor = borderColor;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {
      _borderColor = _focusNode.hasFocus ? primaryColor : borderColor;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = ConstantWidget.getDefaultButtonSize(context);
    final double radius = ConstantWidget.getPercentSize(height, 20);
    final double fontSize = ConstantWidget.getPercentSize(height, 27);
    final double iconSize = ConstantWidget.getPercentSize(height, 40);

    return Container(
      height: height,
      margin: EdgeInsets.symmetric(
          vertical: ConstantWidget.getScreenPercentSize(context, 1.2)),
      alignment: Alignment.centerLeft,
      decoration:
          getDefaultDecoration(radius: radius, borderColor: _borderColor),
      child: TextFormField(
        focusNode: _focusNode,
        maxLines: 1,
        controller: widget.controller,
        textAlign: TextAlign.start,
        obscureText: _obscure,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
            fontFamily: Constants.fontsFamily,
            color: textColor,
            fontWeight: FontWeight.w400,
            fontSize: fontSize),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
              left: ConstantWidget.getWidthPercentSize(context, 4)),
          border: OutlineInputBorder(),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: widget.hint,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() => _obscure = !_obscure);
            },
            splashRadius: iconSize * 0.7,
            icon: Icon(
              _obscure
                  ? Icons.remove_red_eye_outlined
                  : Icons.visibility_off_outlined,
              color: subTextColor,
              size: iconSize,
            ),
          ),
          isDense: true,
          hintStyle: TextStyle(
              fontFamily: Constants.fontsFamily,
              color: subTextColor,
              fontWeight: FontWeight.w400,
              fontSize: fontSize),
        ),
      ),
    );
  }
}