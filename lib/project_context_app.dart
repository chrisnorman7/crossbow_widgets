import 'package:flutter/material.dart';

import 'crossbow_widgets.dart';

/// The top-level app object.
/// [ProjectContextScreen].
class ProjectContextApp extends StatelessWidget {
  /// Create an instance.
  const ProjectContextApp({
    required this.getProjectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContextFunction getProjectContext;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: 'Night Raid',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: ProjectContextScreen(
          getProjectContext: getProjectContext,
        ),
      );
}
