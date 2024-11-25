part of 'home_cubit.dart';

class HomeState {
  final bool loading;
  final XFile? recognitionImage;
  final Map<String, num> recognitions;

  HomeState({
    this.loading = false,
    this.recognitionImage,
    this.recognitions = const {},
  });

  HomeState copyWith({
    bool? loading,
    XFile? recognitionImage,
    Map<String, num>? recognitions,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      recognitionImage: recognitionImage ?? this.recognitionImage,
      recognitions: recognitions ?? this.recognitions,
    );
  }
}
