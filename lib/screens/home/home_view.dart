import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pothole_detector/screens/home/live_detector_view.dart';
import 'package:pothole_detector/shared/constants.dart';
import 'package:pothole_detector/shared/supabase_service.dart';
import 'package:pothole_detector/shared/widgets/custom_button.dart';
import 'package:pothole_detector/shared/yolo_fastapi_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Map<String, num> _recognitions = {};
  XFile? _recognitionImage;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  _loadImage({required bool isCamera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 640,
        maxHeight: 640,
      );
      if (image == null) {
        return;
      }
      setState(() {
        _recognitionImage = image;
        _loading = true;
        _recognitions = {};
      });
      _detectImage(image);
    } catch (e) {
      checkPermissions(context);
    }
  }

  _detectImage(XFile image) async {
    final json = yoloFastApiService.objectDetectionJson(image.path);
    final file = yoloFastApiService.objectDetectionFile(image.path);

    try {
      final results = await Future.wait([json, file]);
      _recognitions = results.first as Map<String, num>;
      _recognitionImage = results.last as XFile;

      recordDataToSupabase();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  // Fungsi untuk mendapatkan lokasi pengguna
  Future<String> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return '${position.latitude},${position.longitude}';
    } catch (e) {
      debugPrint('Error getting location: $e');
      return 'Unknown Location';
    }
  }

  _reset() {
    setState(() {
      _loading = false;
      _recognitionImage = null;
      _recognitions = {};
    });
  }

  // Fungsi untuk merekam data ke Supabase
  void recordDataToSupabase() async {
    if (_recognitions.isNotEmpty) {
      String location = await getCurrentLocation();
      String damageType = recognitionResult(_recognitions.entries.first);

      // Catat data ke Supabase
      await supabaseService.recordData(location, damageType);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    checkPermissions(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 245, 248),
      appBar: AppBar(
        title: const Text("Pavement Detector"),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white
        ),
        backgroundColor: Colors.indigo[800]!,
        actions: [
          if (_loading)
            IconButton(
              onPressed: () => _reset(),
              icon: const FaIcon(FontAwesomeIcons.trash),
            )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              text: "Open camera",
              onPressed: () => _loadImage(isCamera: true),
            ),
            const SizedBox(height: 16),
            AppButton(
              textColor: Colors.white,
              text: "Open gallery",
              onPressed: () => _loadImage(isCamera: false),
            ),
            const SizedBox(height: 16),
            AppButton(
              textColor: Colors.white,
              text: "Live Detection",
              onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LiveDetectorView(),
                        ),
                      ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo[800]!.withOpacity(0.2), // Warna bayangan
                      spreadRadius: 2, // Penyebaran bayangan
                      blurRadius: 10, // Jarak blur
                      offset: Offset(4, 4), // Posisi bayangan (x, y)
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !_loading ? const SizedBox(height: 10) : const Spacer(),
                    _recognitionImage == null
                        ? FaIcon(FontAwesomeIcons.image, size: 150, color: Colors.black26,)
                        : FutureBuilder<Uint8List>(
                            future: _recognitionImage!.readAsBytes(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return FaIcon(FontAwesomeIcons.image, size: 150, color: Colors.black26,);
                              }
                              return Image.memory(snapshot.data!);
                            },
                          ),
                    SizedBox(height: 10),
                    if (!_loading && _recognitions.isNotEmpty) ...{
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ..._recognitions.keys.map((r) {
                            return Text(
                              '$r : ${(_recognitions[r]! * 100).toStringAsFixed(2)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: Colors.indigo[800]!,
                                  ),
                            );
                          }),
                        ],
                      )
                    } else if (_loading)...{
                      const CircularProgressIndicator(),
                    } else ...{
                      Text(
                        "Detect your Image Now.",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                              color: Colors.black26,
                            ),
                      ),
                    },
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
