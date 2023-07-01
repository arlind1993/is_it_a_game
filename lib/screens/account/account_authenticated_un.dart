import 'package:flutter/material.dart';
import 'package:game_template/widgets/button_widget.dart';
import 'package:game_template/widgets/text_widget.dart';

import '../../widgets/text_field_widget.dart';

class AccountUnauthenticated extends StatefulWidget {
  const AccountUnauthenticated({super.key});

  @override
  State<AccountUnauthenticated> createState() => _AccountUnauthenticatedState();
}

class _AccountUnauthenticatedState extends State<AccountUnauthenticated> {
  late FocusNodeController fnc;
  late List<TextFieldWidget> fields;
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
        maxLines: 2,
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
          iconColor: Colors.amber,
          minWidth: 200,
          paddingSpacing: 10,
          borderRadius: 20,
          prefixIcon: Icons.abc,
          textWidget: TextWidget(
            text: "Submit",
            textColor: Colors.green,
            textSize: DefaultTextSizes.large.value,
            textWeight: DefaultTextWeight.bold.value,
          ),
          action: () {
            fields.forEach((element) => element.submitted.value = true);
          },
        ),
        Container(
          width: 2,
          height: 10,
          color: Colors.purple,

        )
      ],
    );
  }
}
