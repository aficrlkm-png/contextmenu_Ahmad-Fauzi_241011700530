import 'package:flutter/material.dart';
// Menggunakan nama project asli kamu: option_context_menu
import 'package:option_context_menu/produk/list_product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Manajemen Produk',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug merah di pojok kanan atas
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Mengaktifkan desain UI Material 3 yang lebih modern
        scaffoldBackgroundColor: Colors.grey[50], // Warna latar belakang aplikasi yang bersih
      ),
      // 🟢 LANGSUNG MENGARAHKAN HALAMAN UTAMA KE PRODUCT LIST PAGE KAMU
      home: const ProductListPage(), 
    );
  }
}