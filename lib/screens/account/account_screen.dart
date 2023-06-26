import 'package:flutter/material.dart';
import 'package:game_template/screens/account/account_authenticated.dart';

import 'account_authenticated_un.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        if(1==0){
          return AccountAuthenticated();
        }else{
          return AccountUnauthenticated();
        }
      },
    );
  }
}
