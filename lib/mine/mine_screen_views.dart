import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:timefly/app_theme.dart';
import 'package:timefly/blocs/habit/habit_bloc.dart';
import 'package:timefly/blocs/habit/habit_state.dart';
import 'package:timefly/login/login_page.dart';
import 'package:timefly/mine/settings_screen.dart';
import 'package:timefly/models/habit.dart';
import 'package:timefly/models/user.dart';
import 'package:timefly/utils/avatar_helper.dart';

class UserInfoView extends StatefulWidget {
  final VoidCallback callback;

  const UserInfoView({Key? key, required this.callback}) : super(key: key);

  @override
  State<UserInfoView> createState() => _UserInfoViewState();
}

class _UserInfoViewState extends State<UserInfoView> {
  @override
  Widget build(BuildContext context) {
    final session = SessionUtils.sharedInstance();
    final user = session.currentUser;
    final displayName =
        (user == null || user.username.isEmpty) ? '编辑名字' : user.username;
    return Container(
      margin: EdgeInsets.only(
          left: 16, top: MediaQuery.of(context).padding.top + 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () async {
              await AvatarHelper.pickAndSaveAvatar(context);
              widget.callback();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              child: ValueListenableBuilder<String?>(
                valueListenable: session.avatarPathNotifier,
                builder: (context, path, _) {
                  if (path != null &&
                      path.isNotEmpty &&
                      File(path).existsSync()) {
                    return Image.file(
                      File(path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }
                  return Image.asset(
                    'assets/images/user_icon.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          GestureDetector(
            onTap: () async {
              if (user == null) {
                await Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return LoginPage();
                }));
                return;
              }
              if (user.username.isEmpty) {
                await Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return SettingsScreen();
                }));
                widget.callback();
              }
            },
            child: Text(
              displayName,
              style: AppTheme.appTheme
                  .headline1(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          )
        ],
      ),
    );
  }
}

class HabitsTotalView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitsBloc, HabitsState>(
      builder: (context, state) {
        if (state is HabitLoadSuccess) {
          List<Habit> habits = state.habits;
          int habitNum = habits.length;
          int checkNum = 0;
          habits.forEach((habit) {
            if (habit.records.isNotEmpty) {
              checkNum += habit.records.length;
            }
          });
          return Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 38),
            child: Row(
              children: [
                Expanded(
                    child: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/images/habit_check.svg',
                      width: 80,
                      height: 80,
                      color: Colors.grey.withOpacity(0.075),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$habitNum',
                          style: AppTheme.appTheme.numHeadline1(
                              fontWeight: FontWeight.bold, fontSize: 27),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '习惯',
                          style: AppTheme.appTheme.headline2(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      ],
                    )
                  ],
                  alignment: Alignment.center,
                )),
                Expanded(
                    child: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/images/bianji.svg',
                      width: 80,
                      height: 80,
                      color: Colors.grey.withOpacity(0.075),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$checkNum',
                          style: AppTheme.appTheme.numHeadline1(
                              fontWeight: FontWeight.bold, fontSize: 27),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '记录',
                          style: AppTheme.appTheme.headline2(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      ],
                    )
                  ],
                  alignment: Alignment.center,
                )),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}

class EnterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 26, right: 26, top: 26),
      child: Row(
        children: [
          Expanded(
              child: AspectRatio(
            aspectRatio: 0.8,
            child:
                _item('assets/images/icon_today.svg', '这一天\n我在这一天...', () {}),
          )),
          SizedBox(
            width: 16,
          ),
          Expanded(
              child: AspectRatio(
            aspectRatio: 0.8,
            child: SizedBox(),
          ))
        ],
      ),
    );
  }

  Widget _item(
    String iconPath,
    String text,
    VoidCallback onTap, {
    BoxDecoration? decoration,
    bool colored = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: decoration ??
            BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: AppTheme.appTheme.cardBackgroundColor(),
                boxShadow: AppTheme.appTheme.containerBoxShadow()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 26,
              height: 26,
              color: colored
                  ? Colors.white
                  : AppTheme.appTheme.grandientColorEnd(),
            ),
            Expanded(child: SizedBox()),
            Text(
              text,
              style: AppTheme.appTheme.headline1(
                  textColor:
                      colored ? Colors.white : AppTheme.appTheme.normalColor(),
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
            SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }
}
