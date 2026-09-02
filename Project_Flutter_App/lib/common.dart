import 'package:flutter/material.dart';

class CommonWidget {
  static Widget renderProgressBar(bool loading) {
    return (loading
        ? LinearProgressIndicator(
            value: null,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          )
        : Container());
  }
}
