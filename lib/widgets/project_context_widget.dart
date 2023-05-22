// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:math';

import 'package:crossbow_backend/crossbow_backend.dart';
import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:dart_tolk/dart_tolk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide KeyboardKey;
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import '../custom_project_runner.dart';
import '../key_conversions.dart';

/// The key code to use.
const keyCode = KeyCode.unknown;

/// A widget to run [projectContext].
class ProjectContextWidget extends StatefulWidget {
  /// Create an instance.
  const ProjectContextWidget({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  @override
  State<ProjectContextWidget> createState() => _ProjectContextWidgetState();
}

class _ProjectContextWidgetState extends State<ProjectContextWidget> {
  /// The project runner to use.
  late final ProjectRunner projectRunner;

  /// The game to use.
  Game? game;

  /// The timer to use.
  Timer? tickTimer;

  /// The project context to work with.
  ProjectContext get projectContext => projectRunner.projectContext;

  /// The title of the keyboard focus.
  late String keyboardFocusTitle;

  /// The tolk instance to use.
  late final Tolk tolk;

  /// The synthizer instance to use.
  late final Synthizer synthizer;

  /// The [synthizer] context to use.
  late final Context synthizerContext;

  /// Initialise state.
  @override
  void initState() {
    tolk = Tolk.windows()
      ..load()
      ..trySapi = true;
    synthizer = Synthizer()..initialize();
    synthizerContext = synthizer.createContext();
    final projectContext = widget.projectContext;
    keyboardFocusTitle = 'Keyboard Area';
    super.initState();
    final random = Random();
    projectRunner = CustomProjectRunner(
      projectContext: projectContext,
      random: random,
      sdl: Sdl(),
      soundBackend: SynthizerSoundBackend(
        context: synthizerContext,
        bufferCache: BufferCache(
          synthizer: synthizer,
          maxSize: 1.gb,
          random: random,
        ),
      ),
      synthizerContext: synthizerContext,
      outputText: (final value) {
        tolk.output(value);
        setState(() => keyboardFocusTitle = value);
      },
    );
    projectRunner.setupGame().then(
      (final _) {
        projectContext.initialCommand.then(
          (final command) => projectRunner.handleCommand(command),
        );
        final ms = (1000 / projectContext.project.framesPerSecond).floor();
        tickTimer = Timer.periodic(
          Duration(milliseconds: ms),
          (final t) => game?.tick(ms),
        );
        setState(
          () {
            game = projectRunner.game;
            keyboardFocusTitle = game!.title;
          },
        );
      },
    );
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    tickTimer?.cancel();
    tickTimer = null;
    game?.destroy();
    synthizerContext.destroy();
    synthizer.shutdown();
    tolk.unload();
  }

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final g = game;
    if (g == null) {
      return const Focus(
        autofocus: true,
        child: CircularProgressIndicator(
          semanticsLabel: 'Loading game...',
        ),
      );
    }
    return getBody(context, g);
  }

  /// Get the body for this widget.
  Widget getBody(final BuildContext context, final Game game) {
    final sdl = game.sdl;
    return Focus(
      autofocus: true,
      onKey: (final node, final event) {
        if (event.repeat) {
          return KeyEventResult.ignored;
        }
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final logicalKey = event.logicalKey;
        final scanCode = keyConversions[logicalKey];
        final modifiers = <KeyMod>{
          if (event.isAltPressed) KeyMod.alt,
          if (event.isControlPressed) KeyMod.ctrl,
          if (event.isMetaPressed) KeyMod.alt,
          if (event.isShiftPressed) KeyMod.shift,
        };
        if (scanCode == null) {
          print(event.logicalKey);
          return KeyEventResult.ignored;
        } else {
          final key = KeyboardKey(
            scancode: scanCode,
            keycode: keyCode,
            modifiers: modifiers,
          );
          if (event is RawKeyDownEvent) {
            game.handleSdlEvent(
              KeyboardEvent(
                sdl,
                timestamp,
                -1,
                PressedState.pressed,
                false,
                key,
              ),
            );
          } else if (event is RawKeyUpEvent) {
            game.handleSdlEvent(
              KeyboardEvent(
                sdl,
                timestamp,
                -1,
                PressedState.released,
                false,
                key,
              ),
            );
          }
        }
        return KeyEventResult.handled;
      },
      child: Text(keyboardFocusTitle),
    );
  }
}
