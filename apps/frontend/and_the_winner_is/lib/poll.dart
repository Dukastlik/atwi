import 'package:and_the_winner_is/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import 'package:and_the_winner_is/models/poll_result.dart';
import 'package:and_the_winner_is/models/user_model.dart';
import 'package:and_the_winner_is/book_progress.dart';
import 'package:and_the_winner_is/common/styles.dart';


class BookPoll extends StatefulWidget {
  // POLL IS A COLLECTION OF BOOK PROGRESSES

  BookPoll({super.key});

  @override
  _BookPollState createState() => _BookPollState();
}

class _BookPollState extends State<BookPoll>  {

    late RiveFile bookAnimationFile;

  void addVote(int bookId){
    try {
      var userInfo = context.read<UserInfo>();
      var pollResult = context.read<PollResult>();
      userInfo.voted();
      pollResult.voteForBook(bookId);
    } catch (e) {_showErrorDialog(e.toString());}
  }

  void retainVotes(){
    try {
      var userInfo = context.read<UserInfo>();
      var pollResult = context.read<PollResult>();
      userInfo.retainVotes();
      pollResult.rollBackVotes();
    } catch (e) {_showErrorDialog(e.toString());}
  }

  Future<void> submitVotes() async{
    try {
      var userInfo = context.read<UserInfo>();
      var pollResult = context.read<PollResult>();
      userInfo.submitVotes();
      await pollResult.submitVotes(userInfo.telegramInitData!);
    } catch (e) {_showErrorDialog(e.toString());}
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(":("),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadRiveFile() async {
      bookAnimationFile = await RiveFile.asset(
        'assets/books_paintless.riv',
      );
    }

  Future<void> loadPollData(BuildContext context) async {
    final pollResult = context.read<PollResult>();
    final userInfo = context.read<UserInfo>();

    await Future.delayed(Duration(milliseconds: 200));
    await loadRiveFile();
    await pollResult.fetchPoll(userInfo.telegramInitData!);
    await userInfo.FetchAdditionalUserInfo();
    // pollResult.fromJson([
    //   {
    //     "book_name": 'Voskresenie',
    //     "book_author": 'Toltoy',
    //     "book_accountable": 'sss',
    //     "bookCoverLink": 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/L.N.Tolstoy_Prokudin-Gorsky.jpg/500px-L.N.Tolstoy_Prokudin-Gorsky.jpg'
    //   },
    //   {
    //     "book_name": 'Odna iz kritik',
    //     "book_author": 'Kant',
    //     "book_accountable": 'sss',
    //     "bookCoverLink": 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Immanuel_Kant_%28painted_portrait%29.jpg/250px-Immanuel_Kant_%28painted_portrait%29.jpg'
    //   },
    //   {
    //     "book_name": '4ya politicheskaya',
    //     "book_author": 'Dugin',
    //     "book_accountable": 'sss',
    //     "bookCoverLink": 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/2023_Aleksandr_Dugin.jpg/250px-2023_Aleksandr_Dugin.jpg'
    //   },
    //   {"book_name": 'Another book', "book_author": 'Random', "book_accountable": 'sss'},
    //   {"book_name": 'Another book', "book_author": 'Random', "book_accountable": 'sss'}
    // ]);
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
    future: loadPollData(context),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Something went wrong!'));
      }
      return Consumer<PollResult>(
        builder: (context, pollResult, child){
          return Column(
            children: [
              SizedBox(
                height: 300, 
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: pollResult.books?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (pollResult != null) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BookProgress(bookId: index, animationFile: bookAnimationFile,),
                          const SizedBox(height: 2,),
                          Text(pollResult.bookPrecentage(index), style: regularTextStyle),
                          const SizedBox(height: 2,),
                          Row(
                            children: [
                              IconButton(
                                color: appTheme.colorScheme.secondary,
                                onPressed: () => addVote(index),
                                icon: const Icon(Icons.how_to_vote)
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return const SizedBox(height: 200,width: 100);
                  }
                )
              ),
              const SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    label: const Text('Retain votes'),
                    onPressed: () => retainVotes(),
                    icon: const Icon(Icons.undo)
                  ),
                  TextButton.icon(
                    label: const Text('Submit votes'),
                    onPressed: () async{await submitVotes();},
                    icon: const Icon(Icons.check)
                  ),
                ],
              )
            ],
          );
        }
      );
    });
  }
}