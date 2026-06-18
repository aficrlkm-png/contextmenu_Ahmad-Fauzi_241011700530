import 'package:flutter/material.dart';
import 'package:option_context_menu/model/Product.dart';
import 'package:option_context_menu/service/api_service.dart';
import 'add_product.dart'; 
import 'detail_product.dart'; 

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> _futureProducts;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _futureProducts = ApiService.getProducts();
    });
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await ApiService.deleteProduct(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus')),
      );
      _refreshProducts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: $e')),
      );
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    return products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             product.descriptions.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshProducts)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada produk.'));
                }

                final filteredProducts = _filterProducts(snapshot.data!);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    
                    // 1. Bungkus dengan InkWell untuk navigasi detail
                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                "${product.imageUrl}?t=${DateTime.now().millisecondsSinceEpoch}",
                                width: 90, height: 90, fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text(product.formattedPrice, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            // Tombol aksi tidak ikut dalam InkWell onTap agar tidak conflict
                            Column(
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () async {
                                  final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductPage(product: product)));
                                  if (res != null) _refreshProducts();
                                }),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(product.id)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage()));
          if (res != null) _refreshProducts();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}