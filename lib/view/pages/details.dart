import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:vecna_app/model/movie.dart';
import 'package:vecna_app/model/details_model.dart';
import 'package:vecna_app/view/pages/main_page.dart';

import '../../constants/constants.dart';
import '../../controller/services.dart';

class DetailsPage extends StatelessWidget {
  DetailsPage({super.key, this.detailsmodel, this.id});

  double? _deviceWidth;
  final details? detailsmodel;
  double? _deviceHeight;
  int? id;
  //https://api.themoviedb.org/3/movie/1927?language=en-US&api_key=44420d3239b17b1920600fd1f7b5df34

  Crud crud = Crud();

  getMoviesDetails() async {
    var response = await crud.getRequest(
        '$BASE_API_URL/movie/${id}?language=en-US&api_key=$API_KEY');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder(
            future: getMoviesDetails(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Stack(
                  children: [
                    ..._buildbackground(
                        context, detailsmodel, snapshot.data['poster_path']),
                    _buildMovieInformation(
                      context,
                      snapshot.data['title'],
                      snapshot.data['release_date'],
                      snapshot.data['status'],
                      snapshot.data['original_language'].toUpperCase(),
                      snapshot.data['overview'],
                      snapshot.data['vote_average'],
                    ),
                    Positioned(
                      top: 30,
                      left: 10,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new),
                        color: Colors.amberAccent,
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ),
                  ],
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.white24,
                ));
              }
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.white24,
              ));
            }));
  }

  Positioned _buildMovieInformation(
      BuildContext context,
      String title,
      String releaseDate,
      String status,
      String language,
      String overview,
      double rating) {
    return Positioned(
      bottom: 40,
      width: _deviceWidth,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '${releaseDate} | ${status} | ${language}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            SizedBox(
              height: 10,
            ),
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              ignoreGestures: true,
              unratedColor: Colors.white,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemCount: 10,
              itemSize: 20,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              overview,
              maxLines: 9,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildbackground(context, details, String image) {
    return [
      Container(
        color: Colors.black,
        width: _deviceWidth,
        height: _deviceHeight,
      ),
      Stack(children: [
        Image.network(
          BASE_IMAGE_API_URL + image,
          width: _deviceWidth,
          height: _deviceHeight! * 0.6,
          fit: BoxFit.cover,
        ),
      ]),
      const Positioned.fill(
          child: DecoratedBox(
              decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 0.6]),
      ))),
    ];
  }
}
