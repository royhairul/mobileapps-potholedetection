part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final Uint8List recognitionImage;
  final Map<String, dynamic> recognitions;

  HomeSuccess({
    required this.recognitionImage,
    required this.recognitions,
  });
}

final class HomeFailure extends HomeState {
  final String error;

  HomeFailure({required this.error});
}