import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/base_alert.dart';

class SuccessAlert {
  final BuildContext context;
  final String title;
  final String text;
  final bool showAction;
  final IconData icon;
  final Duration durationDialog;
  List<Widget> _actions;
  Widget _content;

  SuccessAlert(this.context, {
        this.title,
        this.text,
        this.showAction = false,
        this.icon =  Icons.check_circle_outline_rounded,
        this.durationDialog = const Duration(seconds: 2),
      }) {

    _actions = <Widget>[
      FlatButton(
        child: new Text('Ok', style: label),
        onPressed: () {
          Navigator.pop(context, false);
        },
      ),
    ];

    _content = SingleChildScrollView(
      child: ListBody(children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
               this.icon, color: green_success,
                size: 120,
              ),
              SizedBox(height: 15,),
              Text( text, style: label,),
            ],
          ),
      ])
    );
  }

  Future<bool> show() async => await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if(!this.showAction) {
          Future.delayed(this.durationDialog, () {
            Navigator.pop(context, false);
          });
        }
        return Alert(
          actions: this.showAction?_actions:<Widget>[Container()],
          content: _content,
          title: title,
        );
      });
}
