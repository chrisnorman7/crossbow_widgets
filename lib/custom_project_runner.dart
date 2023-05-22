import 'package:crossbow_backend/crossbow_backend.dart';
import 'package:flutter/material.dart';

import 'custom_game.dart';

/// A custom project runner.
class CustomProjectRunner extends ProjectRunner {
  /// Create an instance.
  CustomProjectRunner({
    required super.projectContext,
    required super.random,
    required super.sdl,
    required super.soundBackend,
    required super.synthizerContext,
    required this.outputText,
  });

  /// The function to use to output text.
  final ValueChanged<String> outputText;

  /// Set up the game.
  @override
  Future<void> setupGame() async {
    final triggerMap = await getTriggerMap();
    game = CustomGame(
      title: projectContext.project.projectName,
      sdl: sdl,
      soundBackend: soundBackend,
      appName: projectContext.project.appName,
      orgName: projectContext.project.orgName,
      random: random,
      triggerMap: triggerMap,
      outputTextFunction: outputText,
    );
  }
}
