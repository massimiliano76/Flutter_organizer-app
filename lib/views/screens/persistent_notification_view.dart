import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/persistent_notification/persistent_notification_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/colors.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/screen_pages/daily_calendar_view.dart';
import 'package:venturiautospurghi/views/screen_pages/operator_list_view.dart';
import 'package:venturiautospurghi/views/screen_pages/user_profile_view.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';
import 'package:venturiautospurghi/views/widgets/reject_alert.dart';

class PersistentNotification extends StatelessWidget {

  List<Event> events;

  PersistentNotification([this.events, Key key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CloudFirestoreService repository = context.repository<CloudFirestoreService>();
    final Account account = context.bloc<AuthenticationBloc>().account;

    return new BlocProvider(
      create: (_) => PersistentNotificationCubit(context, repository, account, events),
      child: Container(
        decoration:
        BoxDecoration(color: white.withOpacity(0.7)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
                child: _notificationWidget()
            )
          ]
        )
      )
    );
  }
}

class _notificationWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    Widget singleNotificationWidget() => cardEvent(
      event: context.bloc<PersistentNotificationCubit>().state.waitingEventsList[0],
      dateView: true,
      gridHourSpan: 0,
      hourHeight: 160,
      buttonArea: <String,Function(Event)>{
        "RIFIUTA": (event) async {RejectAlert(context).show().then((justification)=>!justification.isNullOrEmpty()?context.bloc<PersistentNotificationCubit>().cardActionRefuse(event, justification):null);},
        "CONFERMA": context.bloc<PersistentNotificationCubit>().cardActionConfirm},
      onTapAction: (event) => PlatformUtils.navigator(context, Constants.detailsEventViewRoute, context.bloc<PersistentNotificationCubit>().state.waitingEventsList[0]),
    );

    return BlocBuilder<PersistentNotificationCubit, PersistentNotificationState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return context.bloc<PersistentNotificationCubit>().state.waitingEventsList.length > 0 ?
        context.bloc<PersistentNotificationCubit>().state.waitingEventsList.length > 1 ?
            _multipleNotificationWidget() :
          singleNotificationWidget() :
        Row(children: <Widget>[  Expanded(child: Center(child: CircularProgressIndicator()))]);
      },
    );
  }
}

class _multipleNotificationWidget extends StatelessWidget {
  Map<String, int> eventsGroupedByColor;

  @override
  Widget build(BuildContext context) {
    eventsGroupedByColor = context.bloc<PersistentNotificationCubit>().state
        .waitingEventsList.countBy((event) => event.color.toString());

    void _onNotificationPressed() {
      context.bloc<MobileBloc>().add(NavigateEvent(Constants.waitingEventListRoute, null));
    }

    List<Widget> buildMultipleNotificationWidget = eventsGroupedByColor.map((color, number) => MapEntry(
        Container( width: 30,  height: 30, margin: EdgeInsets.only(right: 15, top: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: HexColor(color)),
            child: Center(
              child: Text("$number", style: button_card),
            )),"")).keys.toList();

    return Card(
      child: Container(
          height: 150,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: Colors.grey),
                      width: 6,
                      height: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('INCARICHI IN SOSPESO', style: button_card,),
                          SizedBox(height: 5),
                          Text('NUMERO DI INCARICHI IN SOSPESO', style: white_default,),
                          Row( children: buildMultipleNotificationWidget,),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(
                          right: 15,
                        ),
                        child: RaisedButton(
                          child: new Text('VISUALIZZA', style: button_card),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(15.0))),
                          color: Colors.grey,
                          elevation: 5,
                          onPressed: () => _onNotificationPressed(),
                        ),
                      ),
                    ])
              ],
            ),
          )),
      elevation: 5,
      color: black,
    );

  }
}
