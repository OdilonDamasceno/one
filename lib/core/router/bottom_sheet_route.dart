import 'package:flutter/material.dart';

class AlertPopup<T> extends PopupRoute<T> {
  AlertPopup(
    this.child, {
    Color? barrierColor,
    bool barrierDismissible = true,
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 200),
    bool canPop = true,
  }) {
    _barrierColor = barrierColor ?? Colors.black.withOpacity(0.5);
    _barrierDismissible = barrierDismissible;
    _barrierLabel = barrierLabel;
    _transitionDuration = transitionDuration;
    _canPop = canPop;
  }

  final Widget child;

  late Color? _barrierColor;

  late bool _barrierDismissible;

  late String? _barrierLabel;

  late Duration _transitionDuration;

  late bool _canPop;

  @override
  Color? get barrierColor => _barrierColor;

  @override
  bool get barrierDismissible => _barrierDismissible && _canPop;

  @override
  String? get barrierLabel => _barrierLabel;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  bool get canPop => _canPop;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * (1 - animation.value)),
          child: child,
        );
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.white,
          child: Material(
            child: child,
          ),
        ),
      ),
    );
  }
}
