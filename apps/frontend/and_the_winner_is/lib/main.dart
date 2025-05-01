import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:and_the_winner_is/common/styles.dart';
import 'package:and_the_winner_is/common/theme.dart';
import 'package:and_the_winner_is/poll.dart';
import 'package:and_the_winner_is/models/poll_result.dart';
import 'package:and_the_winner_is/models/user_model.dart';


void main() async {
  UserInfo user;
  await dotenv.load();
  try {
    if (TelegramWebApp.instance.isSupported) {
      TelegramWebApp.instance.ready();
      Future.delayed(const Duration(seconds: 1), TelegramWebApp.instance.expand);
      user =  UserInfo.fromTelegramData(TelegramWebApp.instance.initData);
    } else {
      user =  UserInfo.fromTelegramData(TelegramInitData.fake());
    }
  } catch (e) {
    print("Error happened in Flutter while loading Telegram $e");
    await Future.delayed(const Duration(milliseconds: 200));
    main();
    return;
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create:(context) => PollResult(books: [])),
        ChangeNotifierProvider(create:(context) =>  user)
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'And the winner is...',
      theme: appTheme,
      home: const MainScreen(title: 'And the winner is ..'),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isAllowed = true;
  bool _checkedTelegram = false;

  @override
  void initState() {
    
    super.initState();
    bool isTeleApp = dotenv.env['IN_TELEGRAM']?.toLowerCase() == 'true';

    if (!isTeleApp){
      setState(() {
        _isAllowed = true;
        _checkedTelegram = true;
      });
        return;
    }

    if (!TelegramWebApp.instance.isSupported) {
      setState(() {
          _isAllowed = false;
          _checkedTelegram = true;
        });
        return;
    }
     _checkedTelegram = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedTelegram) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_isAllowed) {
      return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text( "This is a telegram only app", style: boldTextStyle,)
      ),
    );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                BookPoll(),
                const SizedBox(height: 10,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<UserInfo>(
                      builder: (context, userInfo, child){
                        return Text(textAlign: TextAlign.center,style: boldTextStyle, userInfo.displayVotesLeft());
                      },
                    ),
                  ],
                )
              ]
            ),
        )
        )
     );
  }
}
