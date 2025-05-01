import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:and_the_winner_is/models/poll_result.dart';


String BACK_URL = dotenv.env['API_URL'] ?? 'https://default.url';


Future<dynamic> apiFetchPoll(TelegramInitData authInfo) async {
  final uri = Uri.http(BACK_URL, 'polls/latest');
  final response = await http.get(
    uri,
    headers: {
        "ngrok-skip-browser-warning": "69420",
        'Authorization': 'Bearer ${authInfo.toString()}',
    },
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data;
  } if (response.statusCode == 412) {
      throw Exception(response.toString());
  }
  else {
    throw Exception('Some error');
  }
}

Future<dynamic> apiSubmitVote(TelegramInitData authInfo, PollResult pollResult) async {
  final uri = Uri.http(BACK_URL, 'polls/latest');
  final response = await http.put(
    uri,
    headers: {
        "ngrok-skip-browser-warning": "69420",
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authInfo.toString()}',
    },
    body: jsonEncode(pollResult.toJson())
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data;
  }
  if (response.statusCode == 412) {
      throw Exception(response.body);
  }
  else {
    throw Exception('Some error');
  }
}

Future<Map<String, dynamic>> apiFetchUserInfo(TelegramInitData authInfo) async {
  final uri = Uri.http(BACK_URL, 'users/latest');
  final response = await http.get(
    uri,
    headers: {
        "ngrok-skip-browser-warning": "69420",
        'Authorization': 'Bearer ${authInfo.toString()}',
    },
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data;
  } if (response.statusCode == 412) {
      throw Exception(response.toString());
  }
  else {
    throw Exception('Some error');
  }
}