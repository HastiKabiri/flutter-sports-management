import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

import 'ai_tagging_prototype.dart';

class PerformanceAnalysisPage extends StatelessWidget {
  const PerformanceAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Performance Analysis'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Match Tagging'),
              Tab(text: 'Analytics'),
              Tab(text: 'Video'),
              Tab(text: 'Tactical'),
              Tab(text: 'AI'),
            ],
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
          ],
        ),
        body: const TabBarView(
          children: [
            _MatchTaggingTab(),
            _AnalyticsTab(),
            _VideoTab(),
            _TacticalTab(),
            _AiTab(),
          ],
        ),
      ),
    );
  }
}

class _MatchTaggingTab extends StatefulWidget {
  const _MatchTaggingTab();

  @override
  State<_MatchTaggingTab> createState() => _MatchTaggingTabState();
}

class _MatchTaggingTabState extends State<_MatchTaggingTab> {
  final List<Map<String, dynamic>> _events = [
    {'tag': 'Goal', 'count': 2},
    {'tag': 'Assist', 'count': 1},
    {'tag': 'Turnover', 'count': 4},
    {'tag': 'Interception', 'count': 3},
    {'tag': 'Circle entry', 'count': 6},
    {'tag': 'Shot', 'count': 5},
    {'tag': 'Penalty corner', 'count': 1},
  ];

  void _addTag() {
    setState(() => _events.insert(0, {'tag': 'New tag', 'count': 0}));
  }

  Future<void> _exportMatchTagsCsv() async {
    final rows = <List<String>>[];
    rows.add(['tag', 'count']);
    for (final e in _events) {
      rows.add([e['tag'].toString(), e['count'].toString()]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/match_tags_${DateTime.now().toIso8601String()}.csv',
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
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _events.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, i) {
          final e = _events[i];
          return ListTile(
            leading: const Icon(Icons.flag),
            title: Text(e['tag'] as String),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${e['count']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => e['count'] += 1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            onTap: () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTag,
        tooltip: 'Add tag',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Export tags CSV'),
          onPressed: _exportMatchTagsCsv,
        ),
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  Widget _placeholder(BuildContext c, String label, {double height = 180}) =>
      Container(
        height: height,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(c).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          const Text(
            'Heatmap',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          // simple in-app heatmap (demo)
          const SizedBox(height: 8),
          SizedBox(height: 220, child: HeatmapWidget()),
          const SizedBox(height: 8),
          const Text(
            'Passing statistics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Row(
            children: const [
              _SmallMetric(title: 'Passes', value: '120'),
              SizedBox(width: 8),
              _SmallMetric(title: 'Acc%', value: '82%'),
              SizedBox(width: 8),
              _SmallMetric(title: 'Key Passes', value: '12'),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Passing map',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 160, child: PassingChartWidget()),
          const SizedBox(height: 12),
          const Text(
            'Possession zones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          _placeholder(
            context,
            'Possession zones chart (placeholder)',
            height: 140,
          ),
          const SizedBox(height: 12),
          const Text(
            'Team shape',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          _placeholder(
            context,
            'Team shape visualization (placeholder)',
            height: 120,
          ),
          const SizedBox(height: 12),
          const Text(
            'Performance trends',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          _placeholder(
            context,
            'Trends / sparkline (placeholder)',
            height: 120,
          ),
        ],
      ),
    );
  }
}

class HeatmapWidget extends StatelessWidget {
  const HeatmapWidget({super.key, this.intensities});

  // intensities: rows x cols matrix with values 0..n
  final List<List<int>>? intensities;

  @override
  Widget build(BuildContext context) {
    final matrix =
        intensities ??
        List.generate(6, (r) => List.generate(10, (c) => (r + c) % 6 + 1));
    final maxVal = matrix
        .expand((e) => e)
        .fold<int>(0, (p, e) => e > p ? e : p);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, bc) {
            final cellW = bc.maxWidth / matrix[0].length;
            final cellH = (bc.maxHeight) / matrix.length;
            return Column(
              children: matrix.map((row) {
                return Row(
                  children: row.map((val) {
                    final t = maxVal == 0
                        ? 0.0
                        : (val / maxVal).clamp(0.0, 1.0);
                    return Container(
                      width: cellW,
                      height: cellH,
                      color: Colors.red.withValues(alpha: t * 0.9 + 0.05),
                    );
                  }).toList(),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class PassingChartWidget extends StatelessWidget {
  const PassingChartWidget({super.key, this.data});

  final List<int>? data;

  @override
  Widget build(BuildContext context) {
    final list = data ?? [20, 40, 30, 10, 50];
    final maxV = list.fold<int>(0, (p, e) => e > p ? e : p);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: list.map((v) {
            final height = maxV == 0 ? 2.0 : (v / maxV) * 120;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                height: height,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                child: Center(
                  child: Text(
                    '$v',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoTab extends StatelessWidget {
  const _VideoTab();

  @override
  Widget build(BuildContext context) {
    final clips = [
      {'label': 'Match vs Tigers - 12/07', 'length': '90:00'},
      {'label': 'Friendly vs Falcons - 05/07', 'length': '70:00'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: clips.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) {
        final c = clips[i];
        return ListTile(
          leading: const Icon(Icons.videocam),
          title: Text(c['label']!),
          subtitle: Text(c['length']!),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Play (placeholder)')),
                ),
                icon: const Icon(Icons.play_arrow),
              ),
              IconButton(
                onPressed: () => _requestClip(context, c['label']!),
                icon: const Icon(Icons.cut),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _requestClip(
    BuildContext context,
    String matchLabel,
  ) async {
    // Placeholder: contact backend to request a clip.
    // In production replace with an HTTP call to your video service.
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Clip requested for $matchLabel')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request failed')));
      }
    }
  }
}

class _TacticalTab extends StatelessWidget {
  const _TacticalTab();

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Defensive shape',
        'note': 'Maintain compact line when out of possession',
      },
      {
        'title': 'Pressing triggers',
        'note': 'Press when opponent receives on backline',
      },
      {'title': 'Set-piece roles', 'note': 'Assign attacking corners to #9'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) {
        final it = items[i];
        return ListTile(
          leading: const Icon(Icons.map),
          title: Text(it['title']!),
          subtitle: Text(it['note']!),
          trailing: TextButton(onPressed: () {}, child: const Text('Analyze')),
        );
      },
    );
  }
}

class _AiTab extends StatefulWidget {
  const _AiTab();

  @override
  State<_AiTab> createState() => _AiTabState();
}

class _AiTabState extends State<_AiTab> {
  String _status = 'Idle';
  List<String> _results = [];

  Future<void> _runPrototype() async {
    setState(() {
      _status = 'Running';
      _results = [];
    });

    // Demo: use a small sample event list and run the rule-based tagger
    final sample = [
      {'tag': 'Goal', 'minute': 12},
      {'tag': 'Turnover', 'minute': 24},
      {'tag': 'Assist', 'minute': 12},
    ];
    final out = Tagger.analyzeEvents(sample);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _results = out.map((e) => e.toString()).toList();
      _status = 'Done';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Tagging',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text('Prototype: small rule-based tagger for demo purposes.'),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _runPrototype,
                child: const Text('Run prototype'),
              ),
              const SizedBox(width: 12),
              Text(_status),
            ],
          ),
          const SizedBox(height: 12),
          if (_results.isNotEmpty) ...[
            const Text(
              'Results',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final r in _results) Text(r),
          ],
        ],
      ),
    );
  }
}

// Player-specific performance view (used by parents/coaches)
class PlayerPerformancePage extends StatelessWidget {
  const PlayerPerformancePage({
    super.key,
    required this.playerName,
    this.playerId,
  });

  final String playerName;
  final String? playerId;

  @override
  Widget build(BuildContext context) {
    // demo per-player metrics (would normally be fetched from backend)
    final metrics = {
      'Goals': 8,
      'Assists': 5,
      'Turnovers': 12,
      'Interceptions': 9,
      'Circle entries': 24,
      'Shots': 45,
      'Penalty corners': 3,
    };

    final heat = List.generate(
      6,
      (r) => List.generate(10, (c) => (r * c + 1) % 6 + 1),
    );
    final passing = [12, 18, 14, 30, 25];
    final trend = [2, 3, 4, 5, 6, 5, 7];

    return Scaffold(
      appBar: AppBar(title: Text('$playerName — Performance')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: metrics.entries.map((e) {
                      return Chip(label: Text('${e.key}: ${e.value}'));
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Heatmap', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          HeatmapWidget(intensities: heat),
          const SizedBox(height: 12),
          const Text(
            'Passing statistics',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          PassingChartWidget(data: passing),
          const SizedBox(height: 12),
          const Text(
            'Performance trend (last matches)',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: trend.map((v) {
                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: v * 8.0,
                          width: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 6),
                        Text('$v', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Video highlights',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Goal vs Tigers — 12/07'),
            trailing: TextButton(onPressed: () {}, child: const Text('Play')),
          ),
        ],
      ),
    );
  }
}
