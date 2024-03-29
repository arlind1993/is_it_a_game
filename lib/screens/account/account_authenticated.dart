import 'package:flutter/material.dart';
import 'package:game_template/services/get_it_helper.dart';
import 'package:game_template/widgets/button_widget.dart';
import 'package:game_template/widgets/text_widget.dart';

class AccountAuthenticated extends StatelessWidget {
  const AccountAuthenticated({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ButtonWidget(
          textWidget: TextWidget(
            text: "Sign out"
          ),
          action: () {
            global.auth.logOut().then((value){
              global.screenController.notifyListeners();
            });
          },
        )
      ],
    );
  }
}
