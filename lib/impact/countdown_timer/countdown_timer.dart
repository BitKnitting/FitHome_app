import 'dart:math';

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  CountdownTimer({this.title, this.day, this.hour, this.min})
      : assert(min != null),
        assert(hour != null),
        assert(day != null);
  final String title;
  final int hour;
  final int day;
  final int min;
  @override
  _CountdownTimer createState() => _CountdownTimer();
}

class _CountdownTimer extends State<CountdownTimer>
    with TickerProviderStateMixin {
  AnimationController animationController;
  String get dayString {
    Duration duration =
        animationController.duration * animationController.value;
    return duration.inDays == 0
        ? ' '
        : duration.inDays > 1
            ? '${duration.inDays} days'
            : '${duration.inDays} day';
  }

  String get timerString {
    Duration duration =
        animationController.duration * animationController.value;
    return '${(duration.inHours % 24).toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this,
        duration: Duration(
            days: widget.day, hours: widget.hour, minutes: widget.min));
    animationController.reverse(from: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: 250,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: FractionalOffset.center,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: animationController,
                        builder: (BuildContext context, Widget child) {
                          return CustomPaint(
                              painter: TimerPainter(
                            animation: animationController,
                            backgroundColor: Colors.green,
                            color: Colors.yellow,
                          ));
                        },
                      ),
                    ),
                    Align(
                      alignment: FractionalOffset.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: Text(
                              widget.title,
                              style: Theme.of(context).textTheme.subhead,
                            ),
                          ),
                          Text(dayString,
                              style: Theme.of(context).textTheme.display1),
                          AnimatedBuilder(
                              animation: animationController,
                              builder: (_, Widget child) {
                                return Text(
                                  timerString,
                                  style: Theme.of(context).textTheme.display1,
                                );
                              }),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color backgroundColor;
  final Color color;

  TimerPainter({this.animation, this.backgroundColor, this.color})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * pi;
    canvas.drawArc(Offset.zero & size, pi * 1.5, -progress, false, paint);
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
