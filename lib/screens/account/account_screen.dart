import 'package:flutter/material.dart';
import 'package:game_template/screens/account/account_authenticated.dart';
import 'package:game_template/services/get_it_helper.dart';

import '../../services/firebase/firebase_auth.dart';
import 'account_authenticated_not.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("lol");
    return LayoutBuilder(
      builder: (context, constraint) {
        if(global.auth.currentUser!=null){
          return AccountAuthenticated();
        }else{
          return AccountUnauthenticated();
        }
      },
    );
  }
}
