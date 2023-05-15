import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vecna_app/view/pages/details.dart';

import '../../constants/constants.dart';
import '../../controller/services.dart';
import '../../model/movie.dart';
import '../../model/search_category.dart';
import '../widgets/movie_tile.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Crud crud = Crud();

  double? _deviceWidth;

  double? _deviceHeight;

  TextEditingController? _searchTextFieldController;

  final Crud controller = Get.put(Crud());

  search(String query) async {
    var response = await crud.getRequest(
        '$BASE_API_URL/search/movie?query=${crud.searchQuery}&api_key=$API_KEY');

    return response;
  }

  late ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _searchTextFieldController = TextEditingController();

    return _buildeUI();
  }

  Widget _buildeUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SizedBox(
        width: _deviceWidth,
        height: _deviceHeight!,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _backgroundWidget(),
            _foregroundWidget(),
          ],
        ),
      ),
    );
  }

  Widget _backgroundWidget() {
    return Container(
      width: _deviceWidth,
      height: _deviceHeight,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
              image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _foregroundWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, _deviceHeight! * 0.02, 0, 0),
      width: _deviceWidth! * 0.90,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _toBarWidget(),
          Container(
            height: _deviceHeight! * 0.85,
            padding: EdgeInsets.symmetric(vertical: _deviceHeight! * 0.01),
            child: _movieListViewWidget(),
          ),
        ],
      ),
    );
  }

  Widget _toBarWidget() {
    return Container(
      height: _deviceHeight! * 0.08,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _searchfieldWidget(),
          _categorySelectionWidget(),
        ],
      ),
    );
  }

  Widget _searchfieldWidget() {
    const border = InputBorder.none;
    return SizedBox(
      width: _deviceWidth! * 0.50,
      height: _deviceHeight! * 0.06,
      child: TextField(
        controller: _searchTextFieldController,
        onSubmitted: (input) {
          _searchTextFieldController!.text = input;
          crud.searchQuery = input;
          controller.isSearching = true.obs;
        },
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
            hintStyle: TextStyle(color: Colors.white24),
            focusedBorder: border,
            border: border,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white24,
            ),
            helperStyle: TextStyle(color: Colors.white54),
            filled: false,
            fillColor: Colors.white24,
            hintText: 'Search...'),
      ),
    );
  }

  Widget _categorySelectionWidget() {
    return DropdownButton(
      dropdownColor: Colors.black38,
      value: controller.dropDownMenuValue,
      icon: const Icon(
        Icons.menu,
        color: Colors.white24,
      ),
      underline: Container(
        height: 1,
        color: Colors.white24,
      ),
      onChanged: (value) {
        controller.dropDownMenuValue = value!;
      },
      items: [
        DropdownMenuItem(
          onTap: () {
            controller.isUpcoming = false.obs;
            controller.isSearching = false.obs;
            controller.dropDownMenuValue = SearchCategory.popular;
            setState(() {});
          },
          value: SearchCategory.popular,
          child: Text(
            SearchCategory.popular,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        DropdownMenuItem(
          onTap: () {
            controller.isUpcoming = true.obs;
            controller.isSearching = false.obs;
            controller.dropDownMenuValue = SearchCategory.upcoming;
            setState(() {});
          },
          value: SearchCategory.upcoming,
          child: Text(
            SearchCategory.upcoming,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _movieListViewWidget() {
    return FutureBuilder(
        future: controller.isSearching == true.obs
            ? search(_searchTextFieldController!.text)
            : controller.isUpcoming == false.obs
                ? controller.getMovies()
                : controller.getUpcomingMovies(),
        builder: ((context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return NotificationListener(
              onNotification: (dynamic _onScrollNotification) {
                if (_onScrollNotification is ScrollEndNotification) {
                  final before = _onScrollNotification.metrics.extentBefore;
                  final max = _onScrollNotification.metrics.maxScrollExtent;
                  if (before == max) {
                    controller.pageApi++;
                    setState(() {});
                    controller.scrollUp();
                    return true;
                  }

                  return false;
                }

                return false;
              },
              child: AnimatedList(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  controller: controller.scrollController,
                  initialItemCount: snapshot.data['results'].length,
                  itemBuilder: (BuildContext context, index, animation) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _deviceHeight! * 0.01, horizontal: 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                    id: snapshot.data['results'][index]['id'],
                                  )));
                        },
                        child: SizeTransition(
                          sizeFactor: animation,
                          child: MovieTile(
                            movie:
                                Movie.fromJson(snapshot.data['results'][index]),
                            height: _deviceHeight! * 0.20,
                            width: _deviceWidth! * 0.85,
                          ),
                        ),
                      ),
                    );
                  }),
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
}
