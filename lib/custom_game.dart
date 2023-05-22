import 'package:ziggurat/constants.dart';
import 'package:ziggurat/ziggurat.dart';

/// A game which has a custom [outputText].
class CustomGame extends Game {
  /// Create an instance.
  CustomGame({
    required super.title,
    required super.sdl,
    required super.soundBackend,
    required this.outputTextFunction,
    super.orgName,
    super.appName,
    super.preferencesFileName,
    super.triggerMap,
    super.preferencesKey,
    super.random,
  });

  /// The function to be used by [outputText].
  final ValueChanged<String> outputTextFunction;

  /// Output some [text].
  @override
  void outputText(final String text) {
    outputTextFunction(text);
  }
}
