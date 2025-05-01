import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:and_the_winner_is/api/poll_api.dart';


class VotesException implements Exception {
  final String message;
  VotesException(this.message);
  @override
  String toString() => message;
}



class UserInfo extends ChangeNotifier{
  int? userId;
  String? userName;
  String? firstName;
  String? lastName;
  TelegramInitData? telegramInitData;
  int votesInit;
  int votesLeft = 0;
  bool alreadyVoed = false;

  UserInfo(
    {
      this.userId,
      this.userName,
      this.firstName,
      this.lastName,
      this.telegramInitData,
      this.votesInit = 1
    }
    ) : votesLeft = votesInit;

  factory UserInfo.fromTelegramData(TelegramInitData teledata){
    final user = UserInfo(
      userId: teledata.user.id,
      userName: teledata.user.username,
      firstName: teledata.user.firstname,
      lastName: teledata.user.lastname,
      telegramInitData: teledata,
      votesInit: 0,
    );
    Future.microtask(() => user.notifyListeners());
    return user;
  }

  Future<void> FetchAdditionalUserInfo() async {
    try {
      final data = await apiFetchUserInfo(telegramInitData!);
      votesInit = data['initial_count_count'];
      votesLeft = votesInit;
      alreadyVoed = data['already_voted'];
    } catch (e, s) {
      print(e);
      throw Exception('Could not get user data');
    } finally {
      notifyListeners();
    }
  }

  factory UserInfo.defaultUser(){
    final user = UserInfo(
      userId:1,
      userName:'valera',
      firstName:'petrovich',
      lastName:null,
      votesInit:10
    );
    Future.microtask(() => user.notifyListeners());
    return user;
  }

  @override
  String toString() {
    if (firstName != null || lastName != null){
      return '${firstName ?? ''} ${lastName ?? ''}';
    }
    else{
      return userName ?? 'unkown user';
    }
  }

  String displayVotesLeft() {
    return "${toString()} you've got $votesLeft votes left";
  }

  void voted(){
    if (votesLeft > 0){
      votesLeft -= 1;
      notifyListeners();
    }
    else {
      throw VotesException("You're out of votes");
    }
  }


  void retainVotes(){
    votesLeft = votesInit;
    notifyListeners();
  }

  void submitVotes(){
    votesLeft = 0;
    votesInit = 0;
    notifyListeners();
  }

  



  
}