import 'package:flutter/material.dart';
import 'package:game_template/widgets/button_widget.dart';
import 'package:game_template/widgets/text_widget.dart';

class AccountUnauthenticated extends StatelessWidget {
  const AccountUnauthenticated({super.key});

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
        ButtonWidget(
          backgroundColor: Colors.blue,
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
        )
      ],
    );
  }
}
