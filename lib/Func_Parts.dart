import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as Pacexcel;
import 'package:file_selector/file_selector.dart';

//ページ
import 'KinmuCalendarPage.dart';
import 'database/databasefunc.dart';

class CommonParts {
  

}

class BottomButtonParts {
  ////////////////////////下固定ボタン////////////////////////////////////////
  Widget BottomButtons1(BuildContext _context ,DateTime _selectdate) {
    return FloatingActionButton(
            backgroundColor: Theme.of(_context).colorScheme.secondary,
            onPressed: () {
              InputDialog(_context, _selectdate);
            },
            child: const Icon(Icons.border_color),
          );
  }

  Widget BottomButtons2(BuildContext _context) {
    return SizedBox(
          height: 50,
          child: BottomAppBar(
            // color: Theme.of(context).primaryColor,
            color: Colors.black,
            notchMargin: 5.0,
            shape: const AutomaticNotchedShape(
              RoundedRectangleBorder(),
              StadiumBorder(
                side: BorderSide(),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  //取込みボタン
                  SizedBox.fromSize(
                    size: const Size(50, 50),
                    child: Material(
                      color: Colors.black,
                      shape: Border.all(color: Colors.white),
                      child: InkWell(
                        onTap: () async {
                          //ファイル読み込み
                          var kinmudata = getDataSource();
                          //firebaseに取込
                          await databasefunc().write(await kinmudata as Map);
                          Navigator.pushReplacement(
                              _context,
                              MaterialPageRoute(
                                  builder: (BuildContext _context) => KinmuCalendarPage())
                          );
                        }, 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.file_download, color: Colors.white),
                            Text("入力", style: TextStyle(fontSize: 12, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //設定ボタン
                  SizedBox.fromSize(
                    size: const Size(50, 50),
                    child: Material(
                      color: Colors.black,
                      shape: Border.all(color: Colors.white),
                      child: InkWell(
                        onTap: () {}, 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.settings, color: Colors.white),
                            Text("設定", style: TextStyle(fontSize: 12, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        );
  }
  ////////////////////////下固定ボタン////////////////////////////////////////
}


////////////////////////勤務エクセル読み込み////////////////////////////////////////
Future getDataSource() async {
  var _datasource = <dynamic, dynamic>{};
  
  //エクセル読み込み
  // final file = '\\\\192.168.3.27\\アクト従業員専用\\☆ACTフォルダ\\太田\\勤務日データ.xlsx';
  final XFile? file = await openFile();
  if (file == null) {
	  return null;
  }
  final bytes = file.readAsBytes();
  final excel = Pacexcel.Excel.decodeBytes(await bytes as List<int>);
  final rowsdata = excel.tables['Sheet1']!.rows;

  var _year = rowsdata[0][0]!.value;
  var _month = rowsdata[0][1]!.value;
  var _days = <String, Map>{};//map ["日にち":{"work":"出る出ない","memo":""}]
  
  for(int i = 2; i <= rowsdata[0].length - 1; i++){
    var day = rowsdata[0][i]!.value.toString();
    if(rowsdata[1][i]!.value.toString() == '出勤'){
      _days[day] = {"work":'出勤',"memo":""};
    }else{
      //ノー勤務
      _days[day] = {"work":"","memo":""};
    }
  }
  _datasource["年"] = _year;
  _datasource["月"] = _month;
  _datasource["日"] = _days;

  return _datasource;
}
////////////////////////勤務エクセル読み込み////////////////////////////////////////


////////////////////////勤務1日分入力ダイアログ////////////////////////////////////////
Future<void> InputDialog(BuildContext _context ,DateTime _selectdate) async {    //処理が重い(?)からか、非同期処理にする
  final String _titledate = _selectdate.year.toString() + "/" + _selectdate.month.toString() + "/" + _selectdate.day.toString(); 
  final _kinmudata = (await databasefunc().load(_selectdate.year.toString(),_selectdate.month.toString(),_selectdate.day.toString()))!;
  var _taskName = _kinmudata['memo'].toString();

  return showDialog(
      context: _context,
      builder: (_context) {
        return AlertDialog(
          insetPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          title: Text(_titledate),
          content: Container(
            width: MediaQuery.of(_context).size.width,
            height: 100,
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 5,
              controller: TextEditingController(text: _kinmudata['memo'].toString()),  //ここに初期値
              decoration: InputDecoration(
                hintText: "ここに入力",
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _taskName = value;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'キャンセル',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.pop(_context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async{
                //OKを押したあとの処理
                //firebaseに書き込み
                var _datasource = <dynamic, dynamic>{};
                _datasource["年"] = _selectdate.year.toString();
                _datasource["月"] = _selectdate.month.toString();

                // _kinmudata["work"] = "";//出勤・その他文言
                _kinmudata["memo"] = _taskName;//テキストエリアの文言
                _datasource["日"] = {_selectdate.day.toString():_kinmudata};
                await databasefunc().write(await _datasource as Map);
                Navigator.pop(_context);
              },
            ),
          ],
        );
      });
}
////////////////////////勤務1日分入力ダイアログ////////////////////////////////////////
















