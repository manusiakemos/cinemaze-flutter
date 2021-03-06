import 'package:cinemaze/models/discover_model.dart';
import 'package:cinemaze/services/http_service.dart';
import 'package:cinemaze/variables/variables.dart';
import 'package:cinemaze/widgets/movie_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shape_of_view/shape_of_view.dart';

class AllMovieScreen extends StatefulWidget {
  final bool isMovie;
  final int genreId;

  const AllMovieScreen({Key key, this.isMovie, this.genreId}) : super(key: key);

  @override
  _AllMovieScreenState createState() => _AllMovieScreenState();
}

class _AllMovieScreenState extends State<AllMovieScreen> {
  ScrollController _scrollController = new ScrollController();
  int page = 1;
  bool loadMore = false;

  int get count => listMovies.length;
  List<DiscoverModel> listMovies = [];
  HttpService httpService = new HttpService();

  @override
  void initState() {
    super.initState();
    fetchMovies();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          page < 10) {
        page++;
        fetchMovies();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchMovies() async {
   if(mounted){
     setState(() {
       loadMore = true;
     });
   }
    List<DiscoverModel> discoverModel =
        await httpService.fetchPopularMovie(page: page.toString());
   if(mounted){
     setState(() {
       listMovies.addAll(discoverModel);
       loadMore = false;
     });
   }
  }

  @override
  Widget build(BuildContext context) {
    String _imageName = "assets/images/bg.png";
    String _title =
        widget.isMovie ? "Browse All Movies" : "Browse All TV Series";
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            elevation: 0,
            collapsedHeight: MediaQuery.of(context).size.height * 0.25,
            backgroundColor: Colors.white.withOpacity(0),
            expandedHeight: MediaQuery.of(context).size.height * 0.35,
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Stack(children: [
                ShapeOfView(
                    elevation: 8,
                    shape: ArcShape(
                        direction: ArcDirection.Outside,
                        height: 30,
                        position: ArcPosition.Bottom),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                            Colors.black,
                            Colors.black.withAlpha(30),
                          ])),
                      child: Image.asset(_imageName,
                          fit: BoxFit.cover, width: double.infinity),
                    )),
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: SafeArea(
                    child: Container(
                        child: Center(
                      child: Text(
                        _title,
                        style: headingSliver,
                      ),
                    )),
                  ),
                ),
              ]),
            ),
            // leading: SizedBox(),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.5,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: 2 / 3,
            ),
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: MovieList(
                  id: listMovies[index].id,
                  title:  listMovies[index].title,
                  posterPath: listMovies[index].posterPath,
                  popularity: listMovies[index].voteAverage,
                ),
              );
            }, childCount: listMovies.length),
          ),
          if (loadMore)
            SliverToBoxAdapter(
                child: Container(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()))),
        ],
      ),
    );
  }
}
