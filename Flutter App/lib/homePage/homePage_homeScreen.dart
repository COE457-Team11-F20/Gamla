import 'package:flutter/material.dart';
import 'homePage_Theme.dart';
import 'plantDiary/widgetScreen.dart';

class homePageHomeScreen extends StatefulWidget {
  @override
  _homePageHomeScreen createState() => _homePageHomeScreen();
}

class _homePageHomeScreen extends State<homePageHomeScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;

  Widget tabBody = Container(
    color: homePageTheme.background,
  );

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = WidgetScreen(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: homePageTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
