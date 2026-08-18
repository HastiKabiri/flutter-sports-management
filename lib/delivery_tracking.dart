import 'package:flutter/material.dart';

class DeliveryTrackingPage extends StatelessWidget {
  const DeliveryTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shipments = [
      {'id': 'ORD123', 'status': 'Dispatch', 'eta': '2 days'},
      {'id': 'ORD124', 'status': 'In transit', 'eta': '1 day'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery tracking')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: shipments.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, i) {
          final s = shipments[i];
          return ListTile(
            leading: const Icon(Icons.local_shipping),
            title: Text(s['id']!),
            subtitle: Text('${s['status']} • ETA: ${s['eta']}'),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Details'),
            ),
          );
        },
      ),
    );
  }
}
