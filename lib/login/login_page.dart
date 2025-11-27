import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timefly/models/user.dart';
import 'package:timefly/utils/flash_helper.dart';
import 'package:timefly/utils/system_util.dart';
import 'package:timefly/utils/uuid.dart';
import 'package:timefly/widget/custom_edit_field.dart';

import '../app_theme.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  String phone = '';

  @override
  void initState() {
    _animationController = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUtil.getSystemUiOverlayStyle(
          AppTheme.appTheme.isDark() ? Brightness.light : Brightness.dark),
      child: Scaffold(
        backgroundColor: AppTheme.appTheme.cardBackgroundColor(),
        body: Column(
          children: [
            SizedBox(
              height: 64,
            ),
            Text(
              'Time Fly',
              style: AppTheme.appTheme
                  .headline1(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 48,
            ),
            ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn),
              )),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: CustomEditField(
                  maxLength: 11,
                  autoFucus: false,
                  inputType: TextInputType.phone,
                  initValue: '',
                  hintText: '手机号',
                  hintTextStyle: AppTheme.appTheme
                      .hint(fontWeight: FontWeight.normal, fontSize: 16),
                  textStyle: AppTheme.appTheme
                      .headline1(fontWeight: FontWeight.normal, fontSize: 16),
                  containerDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: AppTheme.appTheme.containerBackgroundColor()),
                  numDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: AppTheme.appTheme.cardBackgroundColor(),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: AppTheme.appTheme.containerBoxShadow()),
                  numTextStyle: AppTheme.appTheme
                      .themeText(fontWeight: FontWeight.bold, fontSize: 15),
                  onValueChanged: (value) {
                    setState(() {
                      phone = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: 48,
            ),
            ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(0.5, 1, curve: Curves.fastOutSlowIn),
              )),
              child: GestureDetector(
                onTap: () async {
                  if (!hasPhone()) {
                    FlashHelper.toast(context, '请输入手机号');
                    return;
                  }
                  User user = User(
                    id: Uuid().generateV4(),
                    username: '',
                    phone: phone,
                  );
                  SessionUtils.sharedInstance().login(user);
                  await FlashHelper.toast(context, '登录成功');
                  Navigator.of(context).pop();
                },
                onDoubleTap: () {},
                child: Container(
                  alignment: Alignment.center,
                  height: 55,
                  width: 220,
                  decoration: BoxDecoration(
                      boxShadow: AppTheme.appTheme.coloredBoxShadow(),
                      gradient: hasPhone()
                          ? AppTheme.appTheme.containerGradient()
                          : AppTheme.appTheme
                              .containerGradientWithOpacity(opacity: 0.5),
                      borderRadius: BorderRadius.all(Radius.circular(35))),
                  child: Text(
                    'Login',
                    style: AppTheme.appTheme.headline1(
                        textColor: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool hasPhone() {
    return phone.length == 11;
  }
}
