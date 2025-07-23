import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pothole_detector/screens/home/cubit/home_cubit.dart';
import 'package:pothole_detector/screens/home/full_view_image.dart';
import 'package:pothole_detector/screens/home/live_detector_view.dart';
import 'package:pothole_detector/shared/constants.dart';
import 'package:pothole_detector/shared/widgets/custom_button.dart';
import 'package:page_transition/page_transition.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    checkPermissions(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeCubit(),
        ),
      ],
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    CircularProgressIndicator(
                      color: Color(COLOR_PRIMARY),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Color(COLOR_PRIMARY)),
                    ),
                  ],
                ),
                backgroundColor: const Color.fromARGB(255, 239, 245, 248),
                shape: Border(
                    top: BorderSide(color: Colors.indigo.shade50, width: 2)),
              ),
            );
          }

          if (state is HomeSuccess) {
            ScaffoldMessenger.of(context)
                .hideCurrentSnackBar(); // Menyembunyikan SnackBar yang sedang tampil
          }

          if (state is HomeFailure) {
            ScaffoldMessenger.of(context)
                .hideCurrentSnackBar(); // Menyembunyikan SnackBar yang sedang tampil

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.faceFrown,
                      color: Colors.white,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.error, style: TextStyle(color: Colors.white)),
                        Text("Detection Not Found", style: TextStyle(color: Colors.white))
                      ]
                    )
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 239, 245, 248),
            appBar: AppBar(
              title: const Text("Pavement Detector"),
              titleTextStyle: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
              backgroundColor: Color(COLOR_PRIMARY),
            ),
            body: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    text: "Open camera",
                    onPressed: context.read<HomeCubit>().fromCamera,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    textColor: Colors.white,
                    text: "Open gallery",
                    onPressed: context.read<HomeCubit>().fromGallery,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    textColor: Colors.white,
                    text: "Live Detection",
                    onPressed: () => Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          duration: const Duration(milliseconds: 100),
                          child: LiveDetectorView(),
                        )),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      // padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade100, width: 5),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo[800]!.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Bagian pertama untuk menampilkan gambar atau ikon jika tidak ada gambar
                          Positioned.fill(
                              child: (state is HomeSuccess)
                                  // Gambar yang terdeteksi
                                  ? InkResponse(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FullScreenImageView(
                                              imageBytes:
                                                  state.recognitionImage,
                                            ),
                                          ),
                                        );
                                      },
                                      child:
                                          Image.memory(state.recognitionImage),
                                    )
                                  // Teks jika tidak ada gambar terdeteksi
                                  : const Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.image,
                                        size: 150,
                                        color: Colors.black26,
                                      ),
                                    )),

                          // Teks hasil deteksi (dengan full width)
                          Positioned(
                            left: 0,
                            right:
                                0, // Membuat Positioned mengambil lebar penuh
                            bottom: 0, // Menempatkan teks di bagian bawah
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: state is HomeSuccess
                                  ? state.recognitions.isEmpty
                                      ? Center(
                                          // Gunakan Center di sini
                                          child: Text(
                                            "Jalan atau Kerusakan tidak ditemukan!",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        )
                                      : Wrap(
                                          children:
                                              state.recognitions.keys.map((r) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    FaIcon(
                                                      FontAwesomeIcons.road,
                                                      color: Color(COLOR_PRIMARY),
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "$r (${(state.recognitions[r][0] * 100).toInt()}%)",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge!
                                                          .copyWith(
                                                            color: Color(COLOR_PRIMARY),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    FaIcon(
                                                      FontAwesomeIcons
                                                          .leftRight,
                                                      color: Color(COLOR_PRIMARY),
                                                      size: 22,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "${state.recognitions[r][1]} m²",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge!
                                                          .copyWith(
                                                            color: Color(COLOR_PRIMARY),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        )
                                  : const Center(
                                      child: Text(
                                        "Detect your Image Now.",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black26,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          if (state is HomeSuccess) ...{
                            Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton.filledTonal(
                                    onPressed: () {
                                      context.read<HomeCubit>().reset();
                                    },
                                    color: Color(COLOR_PRIMARY),
                                    icon: FaIcon(FontAwesomeIcons.trash)))
                          }
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
