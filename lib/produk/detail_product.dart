import 'package:flutter/material.dart';
import '../model/Product.dart';
import 'add_product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 Gambar Besar di Atas (Sesuai Mockup Gambar Kamu)
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: product.imageUrl.isNotEmpty
                  ? Image.network(product.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, size: 80, color: Colors.grey))
                  : const Icon(Icons.image, size: 80, color: Colors.grey),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  // Harga Produk (Warna Hijau)
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  // Tombol Status Stok
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: Text(
                      '${product.stockStatus} (${product.stock} pcs)',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Deskripsi
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      product.descriptions.isNotEmpty ? product.descriptions : 'Tidak ada deskripsi.',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Info Tambahan (ID Produk)
                  Card(
                    color: Colors.grey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ID Produk', style: TextStyle(color: Colors.grey)),
                          Text('#${product.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}