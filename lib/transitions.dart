import 'package:flutter/material.dart';

// One simple reusable fade transition so moving between the
// Home -> Menu -> Checkout -> Orders screens feels smooth and
// consistent instead of the default hard slide-in on every push.
Route fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return page;
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: Duration(milliseconds: 300),
  );
}
