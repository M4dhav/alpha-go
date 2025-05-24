import 'package:alpha_go/views/widgets/search_tile_widget.dart';
import 'package:alpha_go/views/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

enum SearchType { user, place, event, nfts, tags }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> events = ['Music Concert', 'Art Exhibition', 'Tech Conference'];
  List<String> filteredSuggestions = [];
  List<String> nfts = ['CryptoPunk', 'Bored Ape', 'Azuki'];
  List<String> places = ['Paris', 'New York', 'Tokyo'];
  SearchType selectedSearchType = SearchType.user;

  List<String> suggestions = [];
  List<String> tags = ['Art', 'Technology', 'Music'];
  List<String> users = [
    'John Doe',
    'Jane Smith',
    'Tom Jones',
    'Nischal Gautam'
  ];

  @override
  void initState() {
    super.initState();
    getSuggestions();
  }

  void getSuggestions() {
    setState(() {
      switch (selectedSearchType) {
        case SearchType.user:
          suggestions = users;
          break;
        case SearchType.place:
          suggestions = places;
          break;
        case SearchType.event:
          suggestions = events;
          break;
        case SearchType.nfts:
          suggestions = nfts;
          break;
        case SearchType.tags:
          suggestions = tags;
          break;
      }
      filteredSuggestions = List.from(suggestions);
    });
  }

  Widget _buildSearchOption(SearchType type) {
    bool isSelected = selectedSearchType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSearchType = type;
          getSuggestions();
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 4.w),
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.sp),
          border: Border.all(
            color: isSelected ? const Color(0xffb4914b) : Colors.white,
            width: 1.sp,
          ),
        ),
        child: Text(
          type.name,
          style: TextStyle(
            color: isSelected ? const Color(0xffb4914b) : Colors.white,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Search for?',
                  style: TextStyle(
                      color: const Color(0xffb4914b), fontSize: 16.sp)),
              Padding(
                padding: EdgeInsets.only(
                    left: 3.w, right: 3.w, top: 1.h, bottom: 4.h),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SearchType.values.map((type) {
                      return _buildSearchOption(type);
                    }).toList(),
                  ),
                ),
              ),
              SearchBarWidget(
                onSearch: (query) {
                  setState(() {
                    if (query.isEmpty) {
                      filteredSuggestions = List.from(suggestions);
                    } else {
                      filteredSuggestions = suggestions
                          .where((item) =>
                              item.toLowerCase().contains(query.toLowerCase()))
                          .toList();
                    }
                  });
                },
              ),
              SizedBox(height: 4.h),
              Expanded(
                child: ListView(
                  children: filteredSuggestions.map((suggestion) {
                    return SearchResultTile(title: suggestion);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
