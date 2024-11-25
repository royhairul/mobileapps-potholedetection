import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pothole_detector/shared/supabase_service.dart';
import 'package:pothole_detector/shared/yolo_fastapi_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ImagePicker _picker = ImagePicker();

  HomeCubit() : super(HomeState());

  Future<void> loadImage({required bool isCamera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 640,
        maxHeight: 640,
      );

      if (image == null) return;

      emit(state.copyWith(
        loading: true,
        recognitionImage: image,
        recognitions: {},
      ));

      await detectImage(image);
    } catch (e) {
      // Handle error
      debugPrint('Error loading image: $e');
    }
  }

  Future<void> detectImage(XFile image) async {
    try {
      final json = yoloFastApiService.objectDetectionJson(image.path);
      final file = yoloFastApiService.objectDetectionFile(image.path);

      final results = await Future.wait([json, file]);
      final recognitions = results.first as Map<String, num>;

      emit(state.copyWith(
        loading: false,
        recognitions: recognitions,
        recognitionImage: image,
      ));

      recordDataToSupabase(recognitions);
    } catch (e) {
      emit(state.copyWith(loading: false));
      debugPrint('Error detecting image: $e');
    }
  }

  Future<void> recordDataToSupabase(Map<String, num> recognitions) async {
    if (recognitions.isNotEmpty) {
      try {
        final location = await getCurrentLocation();
        final damageType = recognitions.entries.first.key;
        await supabaseService.recordData(location, damageType);
      } catch (e) {
        debugPrint('Error recording to Supabase: $e');
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
      debugPrint('Error getting location: $e');
      return 'Unknown Location';
    }
  }

  void reset() {
    emit(HomeState());
  }
}
