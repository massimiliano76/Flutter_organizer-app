part of 'monthly_calendar_cubit.dart';

abstract class MonthlyCalendarState extends Equatable {
  Map<DateTime, List> eventsMap;
  DateTime selectedMonth;

  MonthlyCalendarState(DateTime selectedMonth, [Map<DateTime, List> eventsMap]):
        this.eventsMap = eventsMap ?? {},
        this.selectedMonth = selectedMonth ?? DateTime.now();

  @override
  List<Object> get props => [eventsMap, selectedMonth];
}

class MonthlyCalendarLoading extends MonthlyCalendarState{
  MonthlyCalendarLoading([DateTime selectedMonth]):super(selectedMonth);
}

class MonthlyCalendarReady extends MonthlyCalendarState {

  List<Event> selectedEvents() => eventsMap[selectedMonth] ?? [];

  MonthlyCalendarReady(Map eventsMap, DateTime selectMonth)
      : super(selectMonth, eventsMap);
}
