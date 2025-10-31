import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../config/tasks_config.dart';

class TaskDropdown extends StatefulWidget {
  final Function(String?)? onTaskSelected;
  final String? initialValue;
  final bool? isDisabled;
  
  const TaskDropdown({
    super.key,
    this.onTaskSelected,
    this.initialValue,
    this.isDisabled,
  });

  @override
  State<TaskDropdown> createState() => _TaskDropdownState();
}

class _TaskDropdownState extends State<TaskDropdown> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isDisabled ?? false;
    
    return DropdownButtonFormField<String>(
      initialValue: widget.initialValue!.isEmpty ? null : widget.initialValue,
      isExpanded: true,
      hint: Text(AppLocalizations.of(context)!.selectTask),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.selectTask,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: isDisabled 
            ? Colors.grey.shade200 
            : Theme.of(context).colorScheme.surface,
        enabled: !isDisabled,
        // suffixIcon: selectedTask != null && !isDisabled
        //     ? IconButton(
        //         icon: const Icon(Icons.clear),
        //         onPressed: () {
        //           setState(() {
        //             selectedTask = null;
        //           });
        //           widget.onTaskSelected?.call(null);
        //         },
        //       )
        //     : null,
      ),
      items: [
        // Add "None" option at the beginning
        DropdownMenuItem<String>(
          value: null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              AppLocalizations.of(context)!.noTask,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        // Add all tasks
        ...TasksConfig.tasks.map((task) {
          return DropdownMenuItem<String>(
            value: task.id,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description.isNotEmpty)
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
      onChanged: isDisabled ? null : (value) {
        // setState(() {
        //   selectedTask = value;
        // });
        widget.onTaskSelected?.call(value);
      },
      selectedItemBuilder: (BuildContext context) {
        return [
          Text(
            AppLocalizations.of(context)!.noTask,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          ...TasksConfig.tasks.map((task) {
            return Text(
              task.name,
              overflow: TextOverflow.ellipsis,
            );
          }),
        ];
      },
    );
  }
}