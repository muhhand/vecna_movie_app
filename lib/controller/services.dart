import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../model/search_category.dart';

class Crud extends GetxController {
  RxBool isSearching = false.obs;
  RxBool isUpcoming = false.obs;
  String searchQuery = '';
  String dropDownMenuValue = SearchCategory.popular;
  dynamic pageApi = 1;

  getRequest(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        return responsebody;
      } else {
        print("${response.statusCode}");
      }
    } catch (e) {
      print("$e");
    }
  }

  Map<String, String> myheaders = {};

  postRequest(String url, Map data) async {
    try {
      var response =
          await http.post(Uri.parse(url), body: data, headers: myheaders);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        return responsebody;
      } else {
        print("${response.statusCode}");
      }
    } catch (e) {
      print("$e");
    }
  }

  getMovies() async {
    var response = await getRequest(
        '$BASE_API_URL/discover/movie?language=en-US&page=${pageApi.toString()}&sort_by=popularity.desc&api_key=$API_KEY');

    return response;
  }

  getUpcomingMovies() async {
    var response = await getRequest(
        '$BASE_API_URL/movie/upcoming?language=en-US&page=1&api_key=$API_KEY');
    return response;
  }

  ScrollController scrollController = ScrollController();

  scrollUp() {
    if (scrollController.hasClients) {
      final position = scrollController.position.minScrollExtent;
      scrollController.animateTo(
        position,
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }
  }
}
