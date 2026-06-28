import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/Constants.dart';
import 'package:workout/IntroModel.dart';
import 'package:workout/SizeConfig.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/router/app_router.dart';

class GuideIntroPage extends StatefulWidget {
  const GuideIntroPage({super.key});

  @override
  State<GuideIntroPage> createState() => _GuideIntroPageState();
}

class _GuideIntroPageState extends State<GuideIntroPage> {
  int _position = 0;
  final controller = PageController();

  List<IntroModel> _introList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _introList = _getFitnessIntroModel();
  }

  List<IntroModel> _getFitnessIntroModel() {
    List<IntroModel> list = [];

    IntroModel m = IntroModel();
    m.id = 1;
    m.name = "Train Like Never\nBefore";
    m.image = 'intro_1.png';
    m.svg = "shape_1.svg";
    m.color = "#EBFFFB".toColor();
    m.desc =
        "Get personalized workout plans designed by professional coaches to help you reach your fitness goals.";
    list.add(m);

    m = IntroModel();
    m.id = 2;
    m.name = "Build Strength &\nEndurance";
    m.image = "intro_3.png";
    m.svg = "shape_2.svg";
    m.color = "#F3FFE3".toColor();
    m.desc =
        "From beginner to advanced, our programs adapt to your level and push you to new heights.";
    list.add(m);

    m = IntroModel();
    m.id = 3;
    m.svg = "shape_3.svg";
    m.name = "Track Your Progress\nEvery Step";
    m.image = "intro_2.png";
    m.color = "#FFF1ED".toColor();
    m.desc =
        "Monitor your workouts, body metrics, and nutrition all in one place to stay on track.";
    list.add(m);

    m = IntroModel();
    m.id = 4;
    m.svg = "shape_4.svg";
    m.name = "Stay Motivated &\nConsistent";
    m.image = "intro_4.png";
    m.color = "#FDF1FF".toColor();
    m.desc =
        "Connect with your coach, set reminders, and build habits that last a lifetime.";
    list.add(m);

    return list;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_position < (_introList.length - 1)) {
      _position++;
      controller.jumpToPage(_position);
      setState(() {});
    } else {
      _skip();
    }
  }

  void _skip() {
    PrefData.setIsIntro(false);
    context.go(AppRoutes.login);
  }

  void _onPageChanged(int page) {
    _position = page;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    if (_introList.isEmpty) return const SizedBox();

    double firstSize = ConstantWidget.getScreenPercentSize(context, 55);
    double remainSize =
        ConstantWidget.getScreenPercentSize(context, 100) - firstSize;
    double defMargin = ConstantWidget.getScreenPercentSize(context, 2);

    return Scaffold(
      backgroundColor: _introList[_position].color!,
      resizeToAvoidBottomInset: false,
      appBar: getNoneAppBar(context, color: _introList[_position].color!),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: _introList.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, position) {
                  return Column(
                    children: [
                      SizedBox(
                        height: ConstantWidget.getScreenPercentSize(
                            context, 2),
                      ),
                      Padding(
                        padding: EdgeInsets.all(defMargin),
                        child: ConstantWidget.getCustomText(
                          _introList[position].name!,
                          Colors.black,
                          2,
                          TextAlign.center,
                          FontWeight.w700,
                          ConstantWidget.getPercentSize(remainSize, 7),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SvgPicture.asset(
                                Constants.assetsImagePath +
                                    _introList[position].svg!,
                              ),
                            ),
                            Center(
                              child: Container(
                                height: firstSize,
                                width:
                                    ConstantWidget.getWidthPercentSize(
                                        context, 90),
                                child: Image.asset(
                                  Constants.assetsImagePath +
                                      _introList[position].image!,
                                  fit: BoxFit.scaleDown,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return Container();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ConstantWidget.getScreenPercentSize(
                            context, 2),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: defMargin),
                        child:
                            ConstantWidget.getCustomTextFontWithSpace(
                          _introList[position].desc!,
                          textColor,
                          5,
                          TextAlign.center,
                          FontWeight.w400,
                          ConstantWidget.getScreenPercentSize(
                              context, 2),
                          Constants.fontsFamily,
                        ),
                      ),
                      SizedBox(
                        height: ConstantWidget.getScreenPercentSize(
                            context, 2),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Dot indicators
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(right: defMargin),
                      height: ConstantWidget.getScreenPercentSize(
                          context, 5),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _introList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          double size = ConstantWidget.getPercentSize(
                            ConstantWidget.getScreenPercentSize(
                                context, 5),
                            24,
                          );
                          return (index == _position)
                              ? Center(
                                  child: Container(
                                    height: size,
                                    width:
                                        ConstantWidget
                                            .getWidthPercentSize(
                                                context, 5),
                                    margin: EdgeInsets.only(
                                        right: (size / 1.2)),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          ConstantWidget.getPercentSize(
                                              size, 100),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: size,
                                  width: size,
                                  margin: EdgeInsets.only(
                                      right: (size / 1.2)),
                                  decoration: BoxDecoration(
                                    color:
                                        accentColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Next / Get Started button
            Container(
              margin: EdgeInsets.symmetric(
                horizontal:
                    ConstantWidget.getWidthPercentSize(context, 4),
              ),
              child: ConstantWidget.getButtonWidget(
                context,
                (_position == (_introList.length - 1))
                    ? 'Get Started'
                    : 'Next',
                accentColor,
                () {
                  _onNext();
                },
              ),
            ),

            SizedBox(
              height:
                  ConstantWidget.getScreenPercentSize(context, 1),
            ),
          ],
        ),
      ),
    );
  }
}
