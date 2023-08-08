import 'package:flutter/material.dart';
import 'package:game_template/services/firebase/firebase_auth.dart';
import 'package:game_template/widgets/button_widget.dart';
import 'package:game_template/widgets/text_widget.dart';

import '../../services/get_it_helper.dart';
import '../../widgets/text_field_widget.dart';
import '../screens_controller.dart';

class AccountUnauthenticated extends StatefulWidget {
  const AccountUnauthenticated({super.key});

  @override
  State<AccountUnauthenticated> createState() => _AccountUnauthenticatedState();
}

class _AccountUnauthenticatedState extends State<AccountUnauthenticated> {
  late FocusNodeController fnc;
  late List<TextFieldWidget> fields;
  late VoidCallback submit;

  @override
  void initState() {
    fnc = FocusNodeController();
    fields = [
      TextFieldWidget(
        focusNodeController: fnc,
        label: "Email",
        placeholder: "Jdoe@email.com",
        backgroundColor: Colors.transparent,
        textFieldTypes: TextFieldTypes.email,
        marginHorizontal: 15,
      ),
      TextFieldWidget(
        focusNodeController: fnc,
        label: "Password",
        backgroundColor: Colors.transparent,
        textFieldTypes: TextFieldTypes.password,
        marginHorizontal: 15,
        maxLines: 1,
      ),
    ];

    submit = () {
      fields.forEach((element) => element.submitted.value = true);
      bool allValid = fields.every((element) => element.isValid());
      if(allValid){
        getIt<FirebaseAuthUser>().registerEmail(
          fields[0].editingController.text,
          fields[1].editingController.text,
        ).then((value){
          if(value != null){
            getIt<ScreensController>().notifyListeners();
            setState(() {});
          }else{
            getIt<FirebaseAuthUser>().signInWithEmail(
              fields[0].editingController.text,
              fields[1].editingController.text,
            ).then((value){
              if(value != null){
                getIt<ScreensController>().notifyListeners();
                setState(() {});
              }
            });
          }
        });
      }
    };
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          child: TextWidget(
            text: "Is It a \nGame",
            textColor: Color(0xFFE87E24),
            textSize: 52,
            textWeight: DefaultTextWeight.thick.value,
            textFamily: DefaultTextFamily.magneto.value,
            strokeColor: Color(0xFFE73243),
            strokeWidth: 2,
            lineHeight: 1.2,
          ),
        ),
        ...fields,
        ButtonWidget(
          focusNodeController: fnc,
          backgroundColor: Colors.white,
          elevation: 10,
          minWidth: 200,
          paddingSpacing: 5,
          borderRadius: 20,
          textWidget: TextWidget(
            text: "Submit",
            textColor: Colors.green,
            textSize: DefaultTextSizes.large.value,
            textWeight: DefaultTextWeight.bold.value,
          ),
          action: submit,
        ),
      ],
    );
  }

}
