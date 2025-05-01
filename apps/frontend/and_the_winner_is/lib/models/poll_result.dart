
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:and_the_winner_is/api/poll_api.dart';
import 'package:and_the_winner_is/models/user_model.dart';


class PollResult extends ChangeNotifier{
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int pollId = 0;
  List<BookPoints>? books = [];
  List<BookPoints> booksBackup = [];
  int sumVotes = 0;
  int sumVotesBackup = 0;

  PollResult({this.books});

  PollResult fromJson(List<dynamic> json, int pollId) {
    this.pollId = pollId;
    books = [];
    booksBackup = [];
    sumVotes = 0;
    sumVotesBackup = 0;
    for(final book in json){
      BookPoints bookpoint = BookPoints.fromJson(book);
      books!.add(bookpoint);
      sumVotes += bookpoint.votesCount;
    }
    for(final book in json){
      BookPoints bookpoint = BookPoints.fromJson(book);
      booksBackup.add(bookpoint);
      sumVotesBackup += bookpoint.votesCount;
    }
    balanceBooksPrc();
    notifyListeners();
    return this;
  }

  Future<void> fetchPoll(TelegramInitData authInfo) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      final data = await apiFetchPoll(authInfo);
      fromJson(data["books"], data["poll_id"]);

    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void balanceBooksPrc(){
    for(final book in books!){
      if (sumVotes > 0) {
        book.votesPrc = (book.votesCount / sumVotes) * 100;
      }
      else {
        book.votesPrc = 0;
      }
    }
  }

  void voteForBook(int bookId){
    try {
      books![bookId].votesCount += 1;
      sumVotes += 1;
    } on Exception catch(_){
      throw Exception('Voted for unknown book');
    }
    balanceBooksPrc();
    notifyListeners();
  }

  void retainVoteForBook(int bookId){
    try {
      if (books![bookId].votesCount > 0){
        books![bookId].votesCount -= 1;
        sumVotes -= 1;
      }
    } on Exception catch(_){
      throw Exception('Voted for unknown book');
    }
    balanceBooksPrc();
    notifyListeners();
  }


  Future<void> submitVotes(TelegramInitData authInfo) async{
    booksBackup = books ?? [];
    sumVotesBackup = sumVotes;
    final data = await apiSubmitVote(authInfo, this);
    fromJson(data["books"], data["poll_id"]);
    notifyListeners();
  }

  void rollBackVotes(){
    books = [];
    for (final book in booksBackup) {
      books!.add(
        BookPoints(
          pollId:pollId,
          bookId: book.bookId,
          bookName: book.bookName,
          bookAuthor: book.bookAuthor,
          bookAccountable:  book.bookAccountable,
          bookCoverLink: book.bookCoverLink,
          votesCount: book.votesCount,
        )
      );
    }
    sumVotes = sumVotesBackup;
    balanceBooksPrc();
    notifyListeners();
  }

  @override
  String toString() {
    String result = "";
    for (int i = 0; i < books!.length; i++) {
      result += "{BOOK$i: votes: ${books![i].votesCount},  votes_prc: ${books![i].votesPrc}}";
    }
    return result;
  }

  Map<String, dynamic> toJson(){
    List<dynamic> booksJson = [];
    for (var book in books!) {
      booksJson.add(book.toJson());
    }
    return {
      "poll_id": pollId,
      "books": books?.map((book) => book.toJson()).toList(),
    };
  }


  String bookPrecentage(int bookIndex) {
    return (
    '${books![bookIndex].votesPrc.toStringAsFixed(1)} % '
    '(${books![bookIndex].votesCount})'
    );
  }

}
    
class BookPoints {
  int pollId;
  int bookId;
  String bookName;
  String bookAuthor;
  String bookAccountable;
  String? bookCoverLink;
  int votesCount;
  double votesPrc;

  BookPoints({
      this.pollId = 0,
      this.bookId = 0,
      this.bookName = 'War and Peace',
      this.bookAuthor = 'Tolstoy',
      this.bookAccountable = 'Mitya',
      this.bookCoverLink = null,
      this.votesCount = 0,
      this.votesPrc = 0.0
    });
  
  factory BookPoints.fromJson(Map<String, dynamic> book) {
    return BookPoints(
        pollId: book['poll_id'],
        bookId: book['book_id'],
        bookName: book['book_name'],
        bookAuthor: book['book_author'],
        bookAccountable: book['book_accountable'],
        bookCoverLink: book['book_cover_link'],
        votesCount: book['votes'],
    );
  }

  dynamic toJson(){
    return {
      "poll_id": pollId,
      "book_id": bookId,
      "book_name": bookName,
      "book_author": bookAuthor,
      "book_accountable": bookAccountable,
      "book_cover_link": bookCoverLink,
      "votes": votesCount
    };
  }
}



