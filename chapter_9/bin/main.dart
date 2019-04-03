import 'dart:io';

import 'package:args/args.dart';

void main(List<String> arguments) {
  var exitCode = 0; //presume success
  final parser = new ArgParser()
    ..addFlag('order', negatable: false, abbr: 'o');

  var argResults = parser.parse(arguments);
}

