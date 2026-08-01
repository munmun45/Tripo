import 'package:flutter/material.dart';

/// Keep corners subtle across the app (max ~10px).
class AppRadii {
  static const double xs = 5;
  static const double sm = 8;
  static const double md = 10;

  static BorderRadius get xsAll => BorderRadius.circular(xs);
  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
}
