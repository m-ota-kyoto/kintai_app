import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async'; 



//取得・保存・削除・追加
class databasefunc {

  final FirebaseFirestore _fdb = FirebaseFirestore.instance;

  /// 取得
  Future<Map<dynamic, dynamic>?> load(var nen, var tuki, var niti) async {
    Map<dynamic, dynamic> getkinmudata;

    // Firestoreからコレクション'kinmu'(QuerySnapshot)の該当条件データを取得してdocsに代入。
    final getdata = await _fdb.collection('test').doc(nen).get();
    if(niti.toString().isEmpty){
      //月丸ごと
      try{
        getkinmudata = getdata.get(tuki);
      }catch(err){
        getkinmudata = {};
      }
    }else{
      //特定の日
      var gettukidata = getdata.get(tuki);
      getkinmudata = gettukidata[niti];
    }

    return  getkinmudata;
  }

  //書き込み 更新か新規かで分かれる
  write(Map kinmudata) async {
    final _nen = kinmudata["年"].toString();
    final _tuki = kinmudata["月"].toString();
    final Map _kinmu = kinmudata["日"];

    final querySnapshot = await _fdb.collection('test');
    //Firestoreからドキュメント（年）取得
    var doc_nen = await querySnapshot.doc(_nen).get();
    if (!doc_nen.exists) {
      //Firestoreドキュメントに年がないとき作成
      try {
        final kinmuRef = querySnapshot.doc(_nen.toString());
        await kinmuRef.set({ });
      } catch (err) {
        //エラー時
      }
    }

    //Firestore該当年からフィールド（月）取得
    var doc_tuki = await querySnapshot.doc(_nen).get();
    //Firestoree該当年に月がないとき作成
    try{
      doc_tuki.get(_tuki);
    }catch(err){
      //エラー時
      await querySnapshot.doc(_nen).update({
        _tuki: {
        },
      });
    }

    //Firestore日データを設定
    /**
     * {
     *  1:{work:"",memo:""},
     *  2:{work:"",memo:""},
     *  etc...
     * }
     * の形にしてUPDATE
    */
    Map<String,Map> kinmu_input_data = {};
    _kinmu.forEach((dynamic key, dynamic value) {
      kinmu_input_data[key] = {"work":value["work"],"memo":value["memo"]};
    });
    if(kinmu_input_data.length != 1){
      try{
        await querySnapshot.doc(_nen).update({
          _tuki: kinmu_input_data,
        });
      }catch(err){
        //エラー時 
      }
    }else{
      //単日編集
      try{
        var _editday = List.from(kinmu_input_data.keys);
        await querySnapshot.doc(_nen).update({
          _tuki+'.'+_editday[0]: kinmu_input_data[_editday[0]],
        });
      }catch(err){
        //エラー時 
      }
    }
  }

}