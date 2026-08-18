import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';

class Player {
  final String name;
  final String ic;
  final DateTime dob;
  final String school;
  final String position;
  final String jerseyNumber;
  final String jmId;
  final String? imageUrl;

  const Player({
    required this.name,
    required this.ic,
    required this.dob,
    required this.school,
    required this.position,
    required this.jerseyNumber,
    required this.jmId,
    this.imageUrl,
  });
}

class PlayerPage extends StatelessWidget {
  final Player player;

  const PlayerPage({super.key, required this.player});

  int _age(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileSection(player: player, age: _age(player.dob)),
            const SizedBox(height: 12),
            _DevelopmentSection(),
            const SizedBox(height: 12),
            _PerformanceSection(),
            const SizedBox(height: 12),
            _MedicalSection(),
            const SizedBox(height: 12),
            _CertificatesSection(),
            const SizedBox(height: 12),
            _EngagementSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatefulWidget {
  final Player player;
  final int age;

  const _ProfileSection({required this.player, required this.age});

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  final GlobalKey _qrKey = GlobalKey();

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value, textAlign: TextAlign.right)),
      ],
    ),
  );

  Future<void> _exportQr() async {
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('QR widget not ready');
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw Exception('Failed to encode image');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.player.jmId}.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved ID to ${file.path}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundImage: player.imageUrl != null
                      ? NetworkImage(player.imageUrl!)
                      : null,
                  child: player.imageUrl == null
                      ? const Icon(Icons.person, size: 42)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        player.position,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Jersey: ${player.jerseyNumber}'),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Digital ID'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(child: SimpleQr(player.jmId, size: 60)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: _exportQr,
                      icon: const Icon(Icons.download),
                      label: const Text('Export ID'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row('IC / Passport', player.ic),
            _row(
              'DOB',
              player.dob.toLocal().toIso8601String().split('T').first,
            ),
            _row('Age', widget.age.toString()),
            _row('School / Institute', player.school),
          ],
        ),
      ),
    );
  }
}

class _DevelopmentSection extends StatefulWidget {
  @override
  State<_DevelopmentSection> createState() => _DevelopmentSectionState();
}

class _DevelopmentSectionState extends State<_DevelopmentSection> {
  bool _stravaConnected = false;
  final List<Map<String, String>> _attendance = [
    {'date': '2026-07-24', 'status': 'Present'},
    {'date': '2026-07-21', 'status': 'Present'},
    {'date': '2026-07-18', 'status': 'Late'},
  ];

  final List<Map<String, String>> _dofeLogs = [
    {'title': 'Expedition 1', 'date': '2025-09-12'},
  ];

  final Map<String, int> _skills = {
    'Passing': 78,
    'Shooting': 84,
    'Tactics': 72,
  };

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionHeader('Development'),
            ListTile(
              title: const Text('Attendance'),
              subtitle: Text('${_attendance.length} recent sessions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showModalBottomSheet(
                context: context,
                builder: (_) => ListView(
                  children: [
                    for (final s in _attendance)
                      ListTile(
                        title: Text(s['date']!),
                        trailing: Text(s['status']!),
                      ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text('Fitness tracking'),
              subtitle: const Text('View recent HR / VO2 trends'),
              trailing: const Icon(Icons.health_and_safety),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Fitness tracking'),
                  content: SizedBox(height: 120, child: _simpleBarChart()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text('Strava integration'),
              subtitle: Text(_stravaConnected ? 'Connected' : 'Not connected'),
              trailing: ElevatedButton(
                onPressed: () =>
                    setState(() => _stravaConnected = !_stravaConnected),
                child: Text(_stravaConnected ? 'Disconnect' : 'Connect'),
              ),
            ),
            ListTile(
              title: const Text('DoFE log book'),
              subtitle: Text('${_dofeLogs.length} entries'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ExpansionTile(
              title: const Text('Skills assessment'),
              children: [
                for (final e in _skills.entries)
                  ListTile(title: Text(e.key), trailing: Text('${e.value}%')),
              ],
            ),
            ListTile(
              title: const Text('Speed / agility tests'),
              subtitle: const Text('View test results and videos'),
              trailing: const Icon(Icons.timer),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Growth tracking'),
              subtitle: const Text('Height & weight history'),
              trailing: const Icon(Icons.height),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleBarChart() {
    final values = [60.0, 70.0, 78.0, 85.0, 90.0];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final v in values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                height: v,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PerformanceSection extends StatefulWidget {
  @override
  State<_PerformanceSection> createState() => _PerformanceSectionState();
}

class _PerformanceSectionState extends State<_PerformanceSection> {
  final List<Map<String, String>> _highlights = [
    {'title': 'Goal vs Rivals', 'time': '00:32'},
    {'title': 'Assist vs Falcons', 'time': '01:12'},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Performance & Tracking',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Fitness Graphs'),
              subtitle: const Text('Weight / Speed / Endurance trends'),
              trailing: const Icon(Icons.insert_chart),
              onTap: () {},
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Video Highlights',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _highlights.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final h = _highlights[i];
                  return Container(
                    width: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Container(color: Colors.black12)),
                        const SizedBox(height: 6),
                        Text(
                          h['title']!,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          h['time']!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalSection extends StatefulWidget {
  const _MedicalSection();

  @override
  State<_MedicalSection> createState() => _MedicalSectionState();
}

class _MedicalSectionState extends State<_MedicalSection> {
  final List<String> _injuries = ['Ankle sprain - 2025-11-12'];
  final List<String> _allergies = ['Peanuts'];
  final String _emergencyContact = 'Parent: +60 12-3456789';
  final double _rehabProgress = 0.6;
  bool _cleared = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'Medical & Injury Records',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        children: [
          ListTile(
            title: const Text('Injury history'),
            subtitle: Text('${_injuries.length} records'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Allergies'),
            subtitle: Text(_allergies.join(', ')),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Emergency contact'),
            subtitle: Text(_emergencyContact),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Rehab progress'),
            subtitle: LinearProgressIndicator(value: _rehabProgress),
            onTap: () {},
          ),
          SwitchListTile(
            title: const Text('Return-to-play clearance'),
            value: _cleared,
            onChanged: (v) => setState(() => _cleared = v),
          ),
        ],
      ),
    );
  }
}

class _CertificatesSection extends StatelessWidget {
  const _CertificatesSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Certificates',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Safeguarding Level 1'),
              trailing: const Icon(Icons.picture_as_pdf),
            ),
            ListTile(
              title: const Text('First Aid Certificate'),
              trailing: const Icon(Icons.picture_as_pdf),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngagementSection extends StatefulWidget {
  const _EngagementSection();

  @override
  State<_EngagementSection> createState() => _EngagementSectionState();
}

class _EngagementSectionState extends State<_EngagementSection> {
  bool _birthdayNotifications = true;
  final List<String> _achievements = ['Rookie of the Month', 'Top Scorer 2025'];
  final List<String> _rewards = ['10% kit discount'];
  final int _ranking = 42;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text(
          'Engagement & Rewards',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        children: [
          SwitchListTile(
            title: const Text('Birthday notifications'),
            value: _birthdayNotifications,
            onChanged: (v) => setState(() => _birthdayNotifications = v),
          ),
          ListTile(
            title: const Text('Achievements'),
            subtitle: Text(_achievements.join(', ')),
          ),
          ListTile(
            title: const Text('Rewards'),
            subtitle: Text(_rewards.join(', ')),
          ),
          ListTile(
            title: const Text('Partner discounts'),
            subtitle: const Text('View offers'),
          ),
          ListTile(
            title: const Text('Ranking system'),
            subtitle: Text('Rank #$_ranking'),
          ),
          ListTile(
            title: const Text('MVP voting'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Vote'),
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleQr extends StatelessWidget {
  final String data;
  final double size;

  const SimpleQr(this.data, {this.size = 72, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SimpleQrPainter(data),
    );
  }
}

class _SimpleQrPainter extends CustomPainter {
  final String data;
  late final QrCode _qr;

  _SimpleQrPainter(this.data) {
    _qr = QrCode(4, QrErrorCorrectLevel.L);
    _qr.addData(data);
    _qr.make();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final modules = _qr.moduleCount;
    final pixel = size.width / (modules + 2); // add quiet zone
    for (int x = 0; x < modules; x++) {
      for (int y = 0; y < modules; y++) {
        if (_qr.isDark(y, x)) {
          final rect = Rect.fromLTWH(
            (x + 1) * pixel,
            (y + 1) * pixel,
            pixel,
            pixel,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
