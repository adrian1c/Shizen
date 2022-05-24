import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shizen_app/mainScaffoldStack.dart';
import 'package:shizen_app/utils/custom_theme.dart';
import 'package:shizen_app/utils/images.dart';
import 'package:sizer/sizer.dart';

class OnboardingPage extends HookWidget {
  OnboardingPage({Key? key}) : super(key: key);

  int changePage(next, pageController, selectedIndex) {
    selectedIndex += next ? 1 : -1;
    pageController.animateToPage(selectedIndex,
        curve: Curves.linear, duration: Duration(milliseconds: 600));
    return selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController();
    final selectedIndex = useState(0);
    return Scaffold(
      backgroundColor: CustomTheme.onboardingColor,
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(60, 130, 60, 130),
        child: Column(
          children: [
            Expanded(
              child: PageView(controller: pageController, children: [
                Column(
                  children: [
                    Text('Welcome to Shizen!',
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: SizedBox(
                            width: double.infinity,
                            height: 30.h,
                            child: Images.onboarding1)),
                    Text('Accomplish.', style: TextStyle(fontSize: 15.sp)),
                  ],
                ),
                Column(children: [
                  Text('',
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: SizedBox(
                          width: double.infinity,
                          height: 30.h,
                          child: Images.onboarding2)),
                  Text('Reflect.', style: TextStyle(fontSize: 15.sp)),
                ]),
                Column(
                  children: [
                    Text('',
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: SizedBox(
                            width: double.infinity,
                            height: 30.h,
                            child: Images.onboarding3)),
                    Text('Socialize.', style: TextStyle(fontSize: 15.sp)),
                  ],
                )
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: selectedIndex.value == 1
                  ? [
                      IconButton(
                          onPressed: () => selectedIndex.value = changePage(
                              false, pageController, selectedIndex.value),
                          icon: Icon(
                            Icons.keyboard_arrow_left_rounded,
                            size: 30,
                          )),
                      IconButton(
                          onPressed: () => selectedIndex.value = changePage(
                              true, pageController, selectedIndex.value),
                          icon: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 30,
                          )),
                    ]
                  : selectedIndex.value == 0
                      ? [
                          Container(),
                          IconButton(
                              onPressed: () => selectedIndex.value = changePage(
                                  true, pageController, selectedIndex.value),
                              icon: Icon(
                                Icons.keyboard_arrow_right_rounded,
                                size: 30,
                              ))
                        ]
                      : [
                          IconButton(
                              onPressed: () => selectedIndex.value = changePage(
                                  false, pageController, selectedIndex.value),
                              icon: Icon(
                                Icons.keyboard_arrow_left_rounded,
                                size: 30,
                              )),
                          TextButton(
                            onPressed: () async {
                              await SharedPreferences.getInstance().then(
                                  (value) => value.setBool('onboarding', true));
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: MainScaffoldStack()),
                                  (route) => route is MainScaffoldStack);
                            },
                            child: Text('START',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(fontSize: 25.sp)),
                          )
                        ],
            )
          ],
        ),
      ),
    );
  }
}
