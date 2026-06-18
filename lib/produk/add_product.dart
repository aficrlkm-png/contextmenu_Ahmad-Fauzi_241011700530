import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Pustaka file picker
import '../model/Product.dart';
import '../service/api_service.dart';
import 'dart:html' as html; // 🟢 Wajib untuk membaca elemen browser
import 'dart:typed_data';   

class AddProductPage extends StatefulWidget {
  final Product? product;
  const AddProductPage({Key? key, this.product}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  PlatformFile? _selectedFile;
  String? _fileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _descController.text = widget.product!.descriptions;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

 // Gunakan library HTML bawaan browser (Aman & Pasti Berhasil di Flutter Web)
  Future<void> _pickImage() async {
    // 🟢 Membuat elemen input file HTML secara dinamis
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*'; // Hanya menerima file gambar
    uploadInput.click(); // Membuka jendela pilih file di komputer

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();

        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) {
          setState(() {
            // Memasukkan nama file teks untuk ditampilkan di UI
            _fileName = file.name;
            
            // 🟢 Membungkus bytes ke dalam PlatformFile secara manual agar cocok dengan ApiService
            _selectedFile = PlatformFile(
              name: file.name,
              size: file.size,
              bytes: reader.result as Uint8List?,
            );
          });
        });
      }
    });
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    Map<String, String> productData = {
      'name': _nameController.text,
      'price': _priceController.text,
      'stock': _stockController.text,
      'descriptions': _descController.text,
    };

    try {
      bool isSuccess;

      if (widget.product == null) {
        isSuccess = await ApiService.addProduct(productData, _selectedFile);
      } else {
        isSuccess = await ApiService.updateProduct(widget.product!.id, productData, _selectedFile);
      }

      if (!mounted) return;

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null 
                ? 'Produk dan gambar berhasil ditambahkan!' 
                : 'Produk berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Gagal menyimpan data ke server.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Produk' : 'Tambah Produk'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Nama produk tidak boleh kosong';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga (Rp)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Harga tidak boleh kosong';
                        if (int.tryParse(value) == null) return 'Harga harus berupa angka';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Stok',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Stok tidak boleh kosong';
                        if (int.tryParse(value) == null) return 'Stok harus berupa angka';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Produk',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Deskripsi tidak boleh kosong';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Komponen tombol unggah berkas gambar
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      color: Colors.grey[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image_search),
                              label: const Text('Pilih File Gambar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _fileName ?? (isEditMode ? 'Menggunakan gambar saat ini' : 'Belum ada gambar terpilih'),
                                style: TextStyle(
                                  color: _fileName != null ? Colors.blue.shade700 : Colors.black54,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: _fileName != null ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        isEditMode ? 'Simpan Perubahan' : 'Tambah Produk Baru',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}