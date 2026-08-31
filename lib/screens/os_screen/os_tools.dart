import 'package:cyber_sleuth/models/os_tool.dart';
import 'package:cyber_sleuth/providers/os_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OsTools extends StatefulWidget {
  const OsTools({super.key});

  @override
  State<OsTools> createState() => _OsToolsState();
}

class _OsToolsState extends State<OsTools> {

  final tools = [
    OsTool(id: 1, name: "File Explorer", iconData: Icons.folder),
    OsTool(id: 2, name: "Hex Editor", iconData: Icons.data_array),
    OsTool(id: 3, name: "Network Inspector", iconData: Icons.network_cell),
    OsTool(id: 4, name: "Disk Cloner", iconData: Icons.sd_storage),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) =>  Column(children: tools.map((tool) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: ref.read(osScreenProvider).activeTool?.id == tool.id ? Theme.of(context).colorScheme.primary.withAlpha(50) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ref.read(osScreenProvider.notifier).setActiveTool(tool);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tool.iconData, size: 28, color: ref.read(osScreenProvider).activeTool?.id == tool.id ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimaryContainer),
                  const SizedBox(height: 4),
                  Text(
                    tool.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: ref.read(osScreenProvider).activeTool?.id == tool.id ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        );
      }).toList(),),
    );
  }
}