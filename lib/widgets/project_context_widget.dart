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

/// The key code to use.
const keyCode = KeyCode.unknown;

/// A key conversion table.
final keyTable = <LogicalKeyboardKey, ScanCode>{
  LogicalKeyboardKey.keyA: ScanCode.a,
  LogicalKeyboardKey.keyB: ScanCode.b,
  LogicalKeyboardKey.keyC: ScanCode.c,
  LogicalKeyboardKey.keyD: ScanCode.d,
  LogicalKeyboardKey.keyE: ScanCode.e,
  LogicalKeyboardKey.keyF: ScanCode.f,
  LogicalKeyboardKey.keyG: ScanCode.g,
  LogicalKeyboardKey.keyH: ScanCode.h,
  LogicalKeyboardKey.keyI: ScanCode.i,
  LogicalKeyboardKey.keyJ: ScanCode.j,
  LogicalKeyboardKey.keyK: ScanCode.k,
  LogicalKeyboardKey.keyL: ScanCode.l,
  LogicalKeyboardKey.keyM: ScanCode.m,
  LogicalKeyboardKey.keyN: ScanCode.n,
  LogicalKeyboardKey.keyO: ScanCode.o,
  LogicalKeyboardKey.keyP: ScanCode.p,
  LogicalKeyboardKey.keyQ: ScanCode.q,
  LogicalKeyboardKey.keyR: ScanCode.r,
  LogicalKeyboardKey.keyS: ScanCode.s,
  LogicalKeyboardKey.keyT: ScanCode.t,
  LogicalKeyboardKey.keyU: ScanCode.u,
  LogicalKeyboardKey.keyV: ScanCode.v,
  LogicalKeyboardKey.keyW: ScanCode.w,
  LogicalKeyboardKey.keyX: ScanCode.x,
  LogicalKeyboardKey.keyY: ScanCode.y,
  LogicalKeyboardKey.keyZ: ScanCode.z,
  LogicalKeyboardKey.digit0: ScanCode.digit0,
  LogicalKeyboardKey.digit1: ScanCode.digit1,
  LogicalKeyboardKey.digit2: ScanCode.digit2,
  LogicalKeyboardKey.digit3: ScanCode.digit3,
  LogicalKeyboardKey.digit4: ScanCode.digit4,
  LogicalKeyboardKey.digit5: ScanCode.digit5,
  LogicalKeyboardKey.digit6: ScanCode.digit6,
  LogicalKeyboardKey.digit7: ScanCode.digit7,
  LogicalKeyboardKey.digit8: ScanCode.digit8,
  LogicalKeyboardKey.digit9: ScanCode.digit9,
  LogicalKeyboardKey.pageDown: ScanCode.pagedown,
  LogicalKeyboardKey.pageUp: ScanCode.pageup,
  LogicalKeyboardKey.arrowDown: ScanCode.down,
  LogicalKeyboardKey.arrowLeft: ScanCode.left,
  LogicalKeyboardKey.arrowRight: ScanCode.right,
  LogicalKeyboardKey.arrowUp: ScanCode.up,
  LogicalKeyboardKey.f1: ScanCode.f1,
  LogicalKeyboardKey.f2: ScanCode.f2,
  LogicalKeyboardKey.f3: ScanCode.f3,
  LogicalKeyboardKey.f4: ScanCode.f4,
  LogicalKeyboardKey.f5: ScanCode.f5,
  LogicalKeyboardKey.f6: ScanCode.f6,
  LogicalKeyboardKey.f7: ScanCode.f7,
  LogicalKeyboardKey.f8: ScanCode.f8,
  LogicalKeyboardKey.f9: ScanCode.f9,
  LogicalKeyboardKey.f10: ScanCode.f10,
  LogicalKeyboardKey.f11: ScanCode.f11,
  LogicalKeyboardKey.f12: ScanCode.f12,
  LogicalKeyboardKey.escape: ScanCode.escape,
  LogicalKeyboardKey.appSwitch: ScanCode.application,
  LogicalKeyboardKey.tab: ScanCode.tab,
  LogicalKeyboardKey.bracketLeft: ScanCode.leftbracket,
  LogicalKeyboardKey.bracketRight: ScanCode.rightbracket,
  LogicalKeyboardKey.backspace: ScanCode.backspace,
  LogicalKeyboardKey.backslash: ScanCode.backslash,
  LogicalKeyboardKey.slash: ScanCode.slash,
  LogicalKeyboardKey.space: ScanCode.space,
  LogicalKeyboardKey.enter: ScanCode.return_,
  LogicalKeyboardKey.home: ScanCode.home,
  LogicalKeyboardKey.end: ScanCode.end,
  LogicalKeyboardKey.delete: ScanCode.delete,
  LogicalKeyboardKey.comma: ScanCode.comma,
  LogicalKeyboardKey.period: ScanCode.period,
  LogicalKeyboardKey.backquote: ScanCode.grave,
  LogicalKeyboardKey.numberSign: ScanCode.kp_hash,
};

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
        final scanCode = keyTable[logicalKey];
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
