import 'dart:typed_data';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pothole_detector/shared/supabase_service.dart';
import 'package:pothole_detector/shared/yolo_fastapi_service.dart';
import 'package:logger/logger.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger(); // Logger instance

  HomeCubit() : super(HomeInitial());

  Future<void> fromCamera() async {
    try {

      // Ambil gambar dari kamera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 640,
        maxHeight: 640,
      );

      if (image == null) {
        emit(HomeInitial());
        return;
      }

      // Deteksi gambar
      await detectImage(image);
    } catch (e) {
      emit(HomeFailure(error: 'Error loading image from camera'));
    }
  }

  Future<void> fromGallery() async {
    try {

      // Ambil gambar dari galeri
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 640,
        maxHeight: 640,
      );

      if (image == null) {
        emit(HomeInitial());
        return;
      }      

      // Deteksi gambar
      await detectImage(image);
    } catch (e) {
      emit(HomeFailure(error: 'Error loading image from gallery'));
    }
  }

    // Fungsi untuk kompresi gambar
  Future<File?> compressImage(File imageFile, {int quality = 80}) async {
    // Kompresi gambar menggunakan flutter_image_compress
    final List<int>? compressedBytes = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      quality: quality,  // Kualitas kompresi
    );

    if (compressedBytes != null) {
      // Simpan gambar yang sudah dikompresi
      final compressedFile = File('${imageFile.parent.path}/compressed_image.jpg')
        ..writeAsBytesSync(compressedBytes);
      return compressedFile;
    }
    return null;
  }

  Future<void> detectImage(XFile image) async {
    try {
      emit(HomeLoading());

      final json = yoloFastApiService.objectDetectionJson(image.path);
      final file = yoloFastApiService.objectDetectionFile(image.path);

      final results = await Future.wait([json, file]);

      final recognitions = results.first as Map<String, dynamic>;
      XFile detectedImage = results.last as XFile;
      final imageBytes = await detectedImage.readAsBytes();

      // Emit state success dengan hasil deteksi
      emit(HomeSuccess(
        recognitionImage: imageBytes,
        recognitions: recognitions,
      ));

      _logger.i("Detector Success");
      _logger.i("${recognitions}");

      // Catat data ke Supabase
      // await recordDataToSupabase(recognitions);
    } catch (e) {
      emit(HomeFailure(error: 'Error detecting image'));
    }
  }

  Future<void> recordDataToSupabase(Map<String, num> recognitions) async {
    if (recognitions.isNotEmpty) {
      try {
        final location = await getCurrentLocation();
        final damageType = recognitions.entries.first.key;
        await supabaseService.recordData(location, damageType);
      } catch (e) {
        emit(HomeFailure(error: 'Error recording to Supabase: $e'));
      }
    }
  }

  Future<String> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return '${position.latitude},${position.longitude}';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  void reset() async {
    emit(HomeInitial());
  }

  @override
  void onChange(Change<HomeState> change) {
    super.onChange(change);
    _logger.i("State change from ${change.currentState} to ${change.nextState}");
  }
}
