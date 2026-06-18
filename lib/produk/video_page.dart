import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({Key? key}) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // URL video contoh untuk streaming
  final String _videoUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  final String _fileName = 'contoh_video.mp4';

  VideoPlayerController? _videoController;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isLocalFileExists = false;
  String _localFilePath = '';

  @override
  void initState() {
    super.initState();
    _checkLocalFile();
  }

  // 1. Memeriksa apakah video sudah pernah diunduh (Offline ready)
  Future<void> _checkLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');
    
    if (await file.exists()) {
      setState(() {
        _isLocalFileExists = true;
        _localFilePath = file.path;
      });
      _initializeVideo(isLocal: true); // Putar offline secara otomatis jika ada
    } else {
      _initializeVideo(isLocal: false); // Putar online/streaming jika belum ada
    }
  }

  // 2. Inisialisasi Kontroler Video (Mendukung Online & Offline)
  Future<void> _initializeVideo({required bool isLocal}) async {
    // Reset controller lama jika ada
    if (_videoController != null) {
      await _videoController!.dispose();
    }

    if (isLocal) {
      // Menggunakan VideoPlayerController.file untuk OFFLINE
      _videoController = VideoPlayerController.file(File(_localFilePath));
    } else {
      // Menggunakan VideoPlayerController.networkUrl untuk ONLINE STREAMING
      _videoController = VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
    }

    try {
      await _videoController!.initialize();
      setState(() {}); // Segarkan UI setelah inisialisasi selesai
    } catch (e) {
      debugPrint('Gagal memuat video: $e');
    }
  }

  // 3. Fungsi Menyimpan Video ke Perangkat (Download Offline)
  Future<void> _downloadVideo() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/$_fileName';

      Dio dio = Dio();
      await dio.download(
        _videoUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
        _isLocalFileExists = true;
        _localFilePath = savePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video berhasil disimpan offline!')),
      );

      // Alihkan pemutaran ke file lokal setelah berhasil download
      _initializeVideo(isLocal: true);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh video: $e')),
      );
    }
  }

  // 4. Fungsi Menghapus File Unduhan
  Future<void> _deleteDownloadedVideo() async {
    if (_isLocalFileExists) {
      final file = File(_localFilePath);
      if (await file.exists()) {
        await file.delete();
      }
      setState(() {
        _isLocalFileExists = false;
        _localFilePath = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File offline dihapus. Kembali ke mode streaming.')),
      );
      _initializeVideo(isLocal: false); // Kembali ke streaming online
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemutar Video'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- AREA PEMUTAR VIDEO ---
            Container(
              color: Colors.black,
              height: 250,
              width: double.infinity,
              child: _videoController != null && _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_videoController!),
                          VideoProgressIndicator(_videoController!, allowScrubbing: true),
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),

            // --- TOMBOL KONTROL PLAY / PAUSE ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: Icon(
                      _videoController != null && _videoController!.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // --- STATUS INDIKATOR & TOMBOL DOWNLOAD ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Status Mode Tampilan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isLocalFileExists ? Icons.offline_pin : Icons.cloud_queue,
                        color: _isLocalFileExists ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLocalFileExists
                            ? 'Mode: Offline (Memutar dari perangkat)'
                            : 'Mode: Streaming Online',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Indikator Progres Download
                  if (_isDownloading) ...[
                    LinearProgressIndicator(value: _downloadProgress),
                    const SizedBox(height: 8),
                    Text('Mengunduh: ${(_downloadProgress * 100).toStringAsFixed(0)}%'),
                  ] else ...[
                    // Tombol Aksi Simpan atau Hapus
                    if (!_isLocalFileExists)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(200, 45),
                        ),
                        onPressed: _downloadVideo,
                        icon: const Icon(Icons.download),
                        label: const Text('Simpan Video Offline'),
                      )
                    else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(200, 45),
                        ),
                        onPressed: _deleteDownloadedVideo,
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus Video Offline'),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}