import 'package:flutter/material.dart';
import 'delivery_tracking.dart';

class Product {
  Product({
    required this.id,
    required this.title,
    required this.category,
    this.price = 0,
    this.sizes,
    this.stock = 0,
    this.image,
  });
  final String id;
  final String title;
  final String category;
  final double price;
  final List<String>? sizes;
  int stock;
  final String? image;
}

class Cart {
  Cart._();
  static final Cart instance = Cart._();
  final Map<String, int> _items = {};

  void add(Product p, [int qty = 1]) {
    _items[p.id] = (_items[p.id] ?? 0) + qty;
  }

  void remove(Product p) {
    _items.remove(p.id);
  }

  int qty(Product p) => _items[p.id] ?? 0;

  void clear() => _items.clear();
}

final List<Product> products = [
  Product(
    id: 'jm_apparel_1',
    title: 'JM Training Jersey',
    category: 'Apparel',
    price: 24.99,
    sizes: ['S', 'M', 'L', 'XL'],
    stock: 12,
  ),
  Product(
    id: 'jm_apparel_2',
    title: 'JM Tournament Jersey',
    category: 'Apparel',
    price: 29.99,
    sizes: ['S', 'M', 'L', 'XL'],
    stock: 8,
  ),
  Product(
    id: 'jm_stick_1',
    title: 'JM Stick - Pro',
    category: 'Stick',
    price: 89.99,
    stock: 5,
  ),
  Product(
    id: 'jm_shinguard_1',
    title: 'Shin Guards - Youth',
    category: 'Shin guards',
    price: 19.99,
    sizes: ['XS', 'S', 'M'],
    stock: 20,
  ),
  Product(
    id: 'partner_obo_1',
    title: 'OBO Protective Glove',
    category: 'Partner Merchandise',
    price: 39.99,
    stock: 6,
  ),
];

class EcommercePage extends StatelessWidget {
  const EcommercePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      'Apparel',
      'Stick',
      'Shin guards',
      'Partner Merchandise',
    ];

    return DefaultTabController(
      length: categories.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('JM Shop'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final c in categories) Tab(text: c),
              const Tab(text: 'Cart'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final c in categories) _CategoryView(category: c),
            const _CartView(),
          ],
        ),
      ),
    );
  }
}

class _CategoryView extends StatefulWidget {
  const _CategoryView({required this.category});
  final String category;

  @override
  State<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<_CategoryView> {
  @override
  Widget build(BuildContext context) {
    final list = widget.category == 'All'
        ? products
        : products.where((p) => p.category == widget.category).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: list.length + (widget.category == 'All' ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) {
        if (widget.category == 'All' && i == 0) return _PartnersPanel();
        final p = list[widget.category == 'All' ? i - 1 : i];
        return ListTile(
          leading: CircleAvatar(child: Text(p.title[0])),
          title: Text(p.title),
          subtitle: Text('£${p.price.toStringAsFixed(2)} • Stock: ${p.stock}'),
          trailing: ElevatedButton(
            onPressed: p.stock > 0
                ? () {
                    Cart.instance.add(p);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart')),
                    );
                  }
                : null,
            child: const Text('Add'),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
          ),
        );
      },
    );
  }
}

class _PartnersPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final partners = [
      {
        'name': 'OBO Hockey',
        'url': 'https://www.obohockey.com/?utm_source=chatgpt.com',
      },
      {
        'name': 'Lila Sports',
        'url': 'https://lilasports.com/?utm_source=chatgpt.com',
      },
      {'name': 'KuKerja', 'url': 'https://kukerja.my/?utm_source=chatgpt.com'},
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Partners',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final p in partners)
              ListTile(
                leading: const Icon(Icons.store),
                title: Text(p['name']!),
                subtitle: Text(p['url']!),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Open ${p['url']} (open externally)')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? _selectedSize;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(title: Text(p.title)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                child: Text(p.title[0], style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              p.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('£${p.price.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            if (p.sizes != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sizes'),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final s in p.sizes!)
                        ChoiceChip(
                          label: Text(s),
                          selected: _selectedSize == s,
                          onSelected: (_) => setState(() => _selectedSize = s),
                        ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Qty:'),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      setState(() => _qty = (_qty - 1).clamp(1, p.stock)),
                  icon: const Icon(Icons.remove),
                ),
                Text('$_qty'),
                IconButton(
                  onPressed: () =>
                      setState(() => _qty = (_qty + 1).clamp(1, p.stock)),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: p.stock > 0
                  ? () {
                      Cart.instance.add(p, _qty);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    }
                  : null,
              child: const Text('Add to cart'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Size guide',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Refer to our size guide: chest/height/weight measurements. (placeholder)',
            ),
            const SizedBox(height: 12),
            const Text(
              'Delivery & stock management',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('Stock: ${p.stock}'),
          ],
        ),
      ),
    );
  }
}

class _CartView extends StatefulWidget {
  const _CartView();

  @override
  State<_CartView> createState() => _CartViewState();
}

class _CartViewState extends State<_CartView> {
  @override
  Widget build(BuildContext context) {
    final items = Cart.instance._items.entries
        .map(
          (e) => MapEntry(products.firstWhere((p) => p.id == e.key), e.value),
        )
        .toList();
    return Column(
      children: [
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Cart is empty'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, i) {
                    final p = items[i].key;
                    final q = items[i].value;
                    return ListTile(
                      title: Text(p.title),
                      subtitle: Text(
                        'Qty: $q • £${(p.price * q).toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() => Cart.instance.remove(p));
                        },
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: items.isEmpty
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CheckoutPage(),
                          ),
                        ),
                  child: const Text('Checkout'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Cart.instance._items.entries
        .map(
          (e) => MapEntry(products.firstWhere((p) => p.id == e.key), e.value),
        )
        .toList();
    final total = items.fold<double>(0, (s, e) => s + e.key.price * e.value);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order summary',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final it in items)
              Text(
                '${it.key.title} x${it.value} — £${(it.key.price * it.value).toStringAsFixed(2)}',
              ),
            const SizedBox(height: 12),
            Text(
              'Total: £${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Open payment gateway (placeholder)'),
                ),
              ),
              child: const Text('Pay now'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeliveryTrackingPage()),
              ),
              child: const Text('Track delivery'),
            ),
          ],
        ),
      ),
    );
  }
}
