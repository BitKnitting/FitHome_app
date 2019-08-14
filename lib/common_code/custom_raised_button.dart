import 'package:flutter/material.dart';

class CustomRaisedButton extends StatefulWidget {
   CustomRaisedButton({
    this.child,
    this.color,
    this.disabledColor = Colors.grey,
    this.borderRadius: 2.0,
    this.height: 50.0,
    this.onPressed,
  }) : assert(borderRadius != null);
  final Widget child;
  final Color color;
  final Color disabledColor;
  final double borderRadius;
  final double height;
  final VoidCallback onPressed;
  @override
  _CustomRaisedButtonState createState() => _CustomRaisedButtonState();
}

class _CustomRaisedButtonState extends State<CustomRaisedButton> {

 

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: RaisedButton(
        child: widget.child,
        color: widget.color,
        disabledColor: widget.disabledColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(widget.borderRadius),
          ),
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}
