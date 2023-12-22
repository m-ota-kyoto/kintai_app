import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

//ページ
import 'database/databasefunc.dart';
import 'Func_Parts.dart';


class KinmuCalendarPage extends StatefulWidget {

  // コンストラクタ
  const KinmuCalendarPage({Key? key}) : super(key: key);
  

  @override
  _KinmuCalendarPageState createState() => _KinmuCalendarPageState();
}


class _KinmuCalendarPageState extends State<KinmuCalendarPage> {

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;
  int _SunDay = DateTime.sunday;
  
  Map<dynamic, dynamic> _kinmuList = {};
  Map<DateTime, List<String>> _eventList = {};

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

    //初回起動時のみ実行
  @override
  void initState() {
    super.initState();
    //ビルド前にデータ取得
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _kinmuList = (await databasefunc().load(_focusedDay.year.toString(),_focusedDay.month.toString(),''))!;
      _kinmuList.forEach((key, value){
        if(value["work"].toString().isNotEmpty) _eventList[DateTime.utc(_focusedDay.year, _focusedDay.month, int.parse(key))] = [value["work"].toString()];
      });

      setState(() { });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid.toString();
    var _BottomButtonParts = BottomButtonParts();


    var _events = LinkedHashMap<DateTime, dynamic>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventList);

    List _getEventForDay(DateTime day) {
      return _events[day] ?? [];
    }

    return Scaffold(
      appBar: AppBar(
        title : Text("カレンダー"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Center(
            child: TableCalendar(
              calendarBuilders: CalendarBuilders(
                markerBuilder: (BuildContext context, date, events) {
                  if (events.isEmpty) return SizedBox();
                  return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          // padding: const EdgeInsets.all(1),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red),
                          ),
                        );
                      });
                },
              ),
              //////////////////////////////////////
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                formatButtonVisible: false,
                decoration: BoxDecoration(
                  color: const Color(0xFF1f1f1f),
                  shape: BoxShape.rectangle,
                  // borderRadius: BorderRadius.circular(5),
                ),
                leftChevronIcon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.black,
                  ),
                ),
                rightChevronIcon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.black,
                  ),
                ),
              ),
              calendarStyle: CalendarStyle(
                cellMargin: const EdgeInsets.all(1),
                todayDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.green,
                  // borderRadius: BorderRadius.circular(5),
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                selectedDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: const Color(0xFF0F9EFF),
                  // borderRadius: BorderRadius.circular(5),
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                outsideDaysVisible: true,
                outsideDecoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF616161),
                  ),
                ),
                outsideTextStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                rowDecoration: const BoxDecoration(
                  color: Color(0xFF1f1f1f),
                ),
                defaultDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  // borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.white,
                  ),
                ),
                weekendDecoration: BoxDecoration(
                  // color: Colors.transparent,
                  color: Colors.red,
                  shape: BoxShape.rectangle,
                  // borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xFF616161),
                  ),
                ),
                defaultTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                weekendTextStyle: const TextStyle(color: Colors.white),
                disabledTextStyle: const TextStyle(color: Colors.white38),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(//曜日文字
                decoration: BoxDecoration(
                  color: Color(0xFF1f1f1f),
                ),
                weekdayStyle: TextStyle(
                  color: Color(0xFFB3B3B3),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                weekendStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              //////////////////////////////////////
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              availableCalendarFormats: {
                CalendarFormat.month: "Month",
              },
              calendarFormat: _format,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _getEventForDay(selectedDay);
                });
              },
              onPageChanged: (focusedDay) async{
                _focusedDay = focusedDay;
                _kinmuList = (await databasefunc().load(focusedDay.year.toString(),focusedDay.month.toString(),''))!;
                _kinmuList.forEach((key, value){
                  if(value["work"].toString().isNotEmpty) _eventList[DateTime.utc(_focusedDay.year, _focusedDay.month, int.parse(key))] = [value["work"].toString()];
                });
                setState((){

                });
              },
              focusedDay: _focusedDay,
              firstDay: DateTime(2022, 9),
              lastDay: DateTime(2050),
              locale: 'ja_JP',
              weekendDays: [_SunDay],
              daysOfWeekHeight: 32,
              eventLoader: _getEventForDay,//イベント日
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: _getEventForDay(_selectedDay)
                  .map((event) => ListTile(
                        title: Text(event.toString()),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _BottomButtonParts.BottomButtons1(context,_selectedDay),
      bottomNavigationBar: _BottomButtonParts.BottomButtons2(context),
    );
  }

}