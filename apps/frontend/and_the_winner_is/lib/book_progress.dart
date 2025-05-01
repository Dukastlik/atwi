import 'dart:io';
import 'package:and_the_winner_is/common/styles.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:and_the_winner_is/models/poll_result.dart';
import 'package:provider/provider.dart';


class BookProgress extends StatefulWidget {
  
  final int bookId;
  rive.RiveFile? animationFile;


  BookProgress(
    {
      super.key,
      this.bookId = 0,
      this.animationFile = null
    }
  );

  @override
  _BookProgressState createState() => _BookProgressState();
}

class _BookProgressState extends State<BookProgress> with SingleTickerProviderStateMixin{

  late double _currentValue = 0;
  late rive.SMIInput<double> _prc;
  late AnimationController _animationController;

  void _updateProgress(double value) {

    double currentProgress = _currentValue;
    double targetProgress = (value).clamp(0.0, 100.0);
    Tween<double> tween = Tween<double>(begin: currentProgress, end: targetProgress);
    

    _animationController.reset();
    _animationController.forward(from: 0.0);

    _animationController.addListener(() {
      setState(() {
        _prc.value = tween.evaluate(_animationController);
      });
    });
    _currentValue = targetProgress;
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PollResult>(context, listen: false);
      provider.addListener(() {
        _updateProgress(provider.books![widget.bookId].votesPrc);
      });
    });
  }

  void _onRiveInit(rive.Artboard artboard) {
      final controller = rive.StateMachineController.fromArtboard(artboard, 'State Machine 1');
      artboard.addController(controller!);
      _prc = controller.findInput('progress')!;

      final provider = Provider.of<PollResult>(context, listen: false);
      final initialPrc = provider.books![widget.bookId].votesPrc;
      _currentValue = initialPrc;
      _prc.value = initialPrc;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollResult>(
      builder: (context, pollResult, child){
      return Stack(
        children: [
          if (pollResult.books![widget.bookId].bookCoverLink != null)
            Opacity(
              opacity: 0.35,
              child: Image.network(
                pollResult.books![widget.bookId].bookCoverLink!,
                fit: BoxFit.cover,
                width: 80,
                height: 180,
              ),
            ),
          Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RotatedBox(
            quarterTurns: 3,
            child: Container(
              width: 220,
              child: Text(
                '${pollResult.books![widget.bookId].bookAuthor} - ${pollResult.books![widget.bookId].bookName}',
                style: regularTextFilled,
              ),
            ),
          ),
            SizedBox(
              height: 180,
              width: 80,
              child: 
              rive.RiveAnimation.direct(
                widget.animationFile!,
                onInit: _onRiveInit
              ),
            ),
          ],
        ),]
      );
      }
    );
  }
}