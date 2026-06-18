import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final String descriptions;
  final int price;
  final String imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.descriptions,
    required this.price,
    required this.imageUrl,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tanpa Nama',
      descriptions: json['descriptions'] ?? '', // 🟢 Sinkron dengan field 'descriptions' Laravel
      price: json['price'] != null ? (double.tryParse(json['price'].toString()) ?? 0).toInt() : 0,
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'] ?? '', // 🟢 Mengambil URL langsung dari asset('storage/...') Laravel
    );
  }

  String get formattedPrice => 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get stockStatus => stock > 0 ? 'Tersedia: $stock' : 'Stok Habis';
  Color get stockColor => stock > 0 ? Colors.green : Colors.red;
}