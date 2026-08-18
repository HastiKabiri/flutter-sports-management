import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CoachDashboardPage extends StatelessWidget {
  const CoachDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coach Dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Attendance'),
              Tab(text: 'Session Planning'),
              Tab(text: 'Templates'),
              Tab(text: 'Drill Library'),
              Tab(text: 'Tactical Board'),
              Tab(text: 'Player Grading'),
              Tab(text: 'Match Upload'),
              Tab(text: 'Injury Reports'),
              Tab(text: 'Team Selection'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AttendanceTab(),
            _SessionPlanningTab(),
            _TemplatesTab(),
            _DrillLibraryTab(),
            _TacticalBoardTab(),
            _PlayerGradingTab(),
            _MatchUploadTab(),
            _InjuryReportsTab(),
            _TeamSelectionTab(),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTab extends StatefulWidget {
  const _AttendanceTab();

  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  final List<Map<String, dynamic>> _players = List.generate(
    14,
    (i) => {'name': 'Player ${i + 1}', 'present': false},
  );

  Future<void> _exportCsv() async {
    final rows = <String>[];
    rows.add('name,present');
    for (final p in _players) {
      rows.add('${p['name']},${p['present'] ? '1' : '0'}');
    }
    final csv = rows.join('\n');
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/attendance_${DateTime.now().toIso8601String()}.csv',
      );
      await file.writeAsString(csv);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Exported to ${file.path}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _players.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) {
              final p = _players[i];
              return ListTile(
                leading: CircleAvatar(child: Text(p['name'][0])),
                title: Text(p['name']),
                trailing: Checkbox(
                  value: p['present'] as bool,
                  onChanged: (v) => setState(() => p['present'] = v ?? false),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _exportCsv,
                icon: const Icon(Icons.download),
                label: const Text('Export CSV'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => setState(
                  () => _players.forEach((p) => p['present'] = true),
                ),
                icon: const Icon(Icons.check),
                label: const Text('Mark All Present'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionPlanningTab extends StatelessWidget {
  const _SessionPlanningTab();

  @override
  Widget build(BuildContext context) {
    final sessions = [
      {'title': 'Warm-up & Passing', 'time': '18:00'},
      {'title': 'Tactical drill', 'time': '18:45'},
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) {
        final s = sessions[i];
        return ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(s['title']!),
          subtitle: Text(s['time']!),
          trailing: TextButton(onPressed: () {}, child: const Text('Edit')),
        );
      },
    );
  }
}

class _TemplatesTab extends StatefulWidget {
  const _TemplatesTab();

  @override
  State<_TemplatesTab> createState() => _TemplatesTabState();
}

class _TemplatesTabState extends State<_TemplatesTab> {
  final List<String> _templates = ['Basic Practice', 'Set-piece Session'];
  final TextEditingController _new = TextEditingController();

  @override
  void dispose() {
    _new.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _new,
                  decoration: const InputDecoration(
                    hintText: 'New template name',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_new.text.trim().isNotEmpty) {
                    setState(() {
                      _templates.insert(0, _new.text.trim());
                      _new.clear();
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _templates.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.copy),
              title: Text(_templates[i]),
              trailing: TextButton(onPressed: () {}, child: const Text('Use')),
            ),
          ),
        ),
      ],
    );
  }
}

class _DrillLibraryTab extends StatefulWidget {
  const _DrillLibraryTab();

  @override
  State<_DrillLibraryTab> createState() => _DrillLibraryTabState();
}

class _DrillLibraryTabState extends State<_DrillLibraryTab> {
  final List<Map<String, String>> _drills = [
    {'name': 'Passing Circuit', 'time': '10m'},
    {'name': 'Shooting at Goal', 'time': '15m'},
  ];
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final visible = _drills
        .where((d) => d['name']!.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search drills',
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: visible.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.sports),
              title: Text(visible[i]['name']!),
              subtitle: Text(visible[i]['time']!),
              trailing: TextButton(onPressed: () {}, child: const Text('Add')),
            ),
          ),
        ),
      ],
    );
  }
}

class _TacticalBoardTab extends StatelessWidget {
  const _TacticalBoardTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.map, size: 64),
          SizedBox(height: 12),
          Text('Tactical board canvas placeholder'),
        ],
      ),
    );
  }
}

class _PlayerGradingTab extends StatefulWidget {
  const _PlayerGradingTab();

  @override
  State<_PlayerGradingTab> createState() => _PlayerGradingTabState();
}

class _PlayerGradingTabState extends State<_PlayerGradingTab> {
  final List<Map<String, dynamic>> _players = List.generate(
    14,
    (i) => {'name': 'Player ${i + 1}', 'grade': 'B'},
  );
  final List<String> _grades = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _players.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) {
        final p = _players[i];
        return ListTile(
          leading: CircleAvatar(child: Text(p['name'][0])),
          title: Text(p['name']),
          trailing: DropdownButton<String>(
            value: p['grade'],
            items: _grades
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => setState(() => p['grade'] = v ?? 'B'),
          ),
        );
      },
    );
  }
}

class _MatchUploadTab extends StatelessWidget {
  const _MatchUploadTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload flow placeholder')),
        ),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Match Analysis'),
      ),
    );
  }
}

class _InjuryReportsTab extends StatefulWidget {
  const _InjuryReportsTab();

  @override
  State<_InjuryReportsTab> createState() => _InjuryReportsTabState();
}

class _InjuryReportsTabState extends State<_InjuryReportsTab> {
  final List<Map<String, String>> _reports = [];
  final TextEditingController _desc = TextEditingController();

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  void _addReport() {
    if (_desc.text.trim().isEmpty) return;
    setState(() {
      _reports.insert(0, {
        'desc': _desc.text.trim(),
        'date': DateTime.now().toIso8601String(),
      });
      _desc.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _desc,
            decoration: const InputDecoration(hintText: 'Describe injury'),
          ),
        ),
        ElevatedButton(onPressed: _addReport, child: const Text('Add report')),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _reports.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) => ListTile(
              title: Text(_reports[i]['desc']!),
              subtitle: Text(_reports[i]['date']!),
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamSelectionTab extends StatefulWidget {
  const _TeamSelectionTab();

  @override
  State<_TeamSelectionTab> createState() => _TeamSelectionTabState();
}

class _TeamSelectionTabState extends State<_TeamSelectionTab> {
  final List<Map<String, dynamic>> _players = List.generate(
    20,
    (i) => {'name': 'Player ${i + 1}', 'selected': false},
  );

  void _applySelection() {
    final selected = _players
        .where((p) => p['selected'] == true)
        .map((p) => p['name'])
        .toList();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected: ${selected.join(', ')}')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _players.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) {
              final name = _players[i]['name'] as String;
              return ListTile(
                leading: CircleAvatar(
                  child: Text(name.isNotEmpty ? name[0] : '?'),
                ),
                title: Text(name),
                trailing: Checkbox(
                  value: _players[i]['selected'] as bool? ?? false,
                  onChanged: (v) =>
                      setState(() => _players[i]['selected'] = v ?? false),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: _applySelection,
            child: const Text('Apply Selection'),
          ),
        ),
      ],
    );
  }
}
