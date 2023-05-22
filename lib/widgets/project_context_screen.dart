import 'package:crossbow_backend/crossbow_backend.dart';
import 'package:flutter/material.dart';

import 'project_context_widget.dart';

/// A screen to create and display a project context.
class ProjectContextScreen extends StatefulWidget {
  /// Create an instance.
  const ProjectContextScreen({
    required this.getProjectContext,
    super.key,
  });

  /// The function to call to get a project context.
  final ProjectContext Function() getProjectContext;
  @override
  State<ProjectContextScreen> createState() => _ProjectContextScreenState();
}

class _ProjectContextScreenState extends State<ProjectContextScreen> {
  /// The project context to use.
  late final ProjectContext projectContext;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    projectContext = widget.getProjectContext();
  }

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('Something to focus on'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Something else to focus on'),
            )
          ],
          title: Text(projectContext.project.projectName),
        ),
        body: ProjectContextWidget(projectContext: projectContext),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Does Nothing',
        ),
      );
}
