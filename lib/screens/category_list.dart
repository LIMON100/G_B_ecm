// import 'package:ecom_flutter/custom/box_decorations.dart';
// import 'package:ecom_flutter/custom/btn.dart';
// import 'package:ecom_flutter/custom/device_info.dart';
// import 'package:ecom_flutter/custom/useful_elements.dart';
// import 'package:ecom_flutter/data_model/category_response.dart';
// import 'package:ecom_flutter/helpers/shimmer_helper.dart';
// import 'package:ecom_flutter/presenter/bottom_appbar_index.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:ecom_flutter/my_theme.dart';
// import 'package:ecom_flutter/ui_sections/drawer.dart';
// import 'package:ecom_flutter/custom/toast_component.dart';
// import 'package:toast/toast.dart';
// import 'package:ecom_flutter/screens/category_products.dart';
// import 'package:ecom_flutter/repositories/category_repository.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:ecom_flutter/app_config.dart';
// import 'package:ecom_flutter/helpers/shared_value_helper.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//
// class CategoryList extends StatefulWidget {
//   CategoryList(
//       {Key? key,
//       this.parent_category_id = 0,
//       this.parent_category_name = "",
//       this.is_base_category = false,
//       this.is_top_category = false,
//       this.bottomAppbarIndex})
//       : super(key: key);
//
//   final int parent_category_id;
//   final String parent_category_name;
//   final bool is_base_category;
//   final bool is_top_category;
//   final BottomAppbarIndex? bottomAppbarIndex;
//
//   @override
//   _CategoryListState createState() => _CategoryListState();
// }
//
// class _CategoryListState extends State<CategoryList> {
//
//   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//
//
//
//
//   @override
//   void initState() {
//
//     // TODO: implement initState
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Directionality(
//       textDirection: app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
//       child: Stack(children: [
//         Container(
//           height: DeviceInfo(context).height! / 4,
//           width: DeviceInfo(context).width,
//           // color: Colors.orange,
//           color: Colors.orange,
//           alignment: Alignment.topRight,
//           child: Image.asset(
//             "assets/background_1.png",
//           ),
//         ),
//         Scaffold(
//           backgroundColor:Colors.transparent,
//           appBar: PreferredSize(
//               child: buildAppBar(context),
//               preferredSize:Size(DeviceInfo(context).width!,50,)),
//             body: buildBody()
//         ),
//
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: widget.is_base_category || widget.is_top_category
//               ? Container(
//                   height: 0,
//                 )
//               : buildBottomContainer(),
//         )
//       ]),
//     );
//   }
//
//   Widget buildBody() {
//     return CustomScrollView(
//       physics: AlwaysScrollableScrollPhysics(),
//       slivers: [
//         SliverList(
//             delegate: SliverChildListDelegate([
//
//           buildCategoryList(),
//           Container(
//             height: widget.is_base_category ? 60 : 90,
//           )
//         ]))
//       ],
//     );
//   }
//
//   AppBar buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       //centerTitle: true,
//       leading: widget.is_base_category
//           ? Builder(
//             builder: (context) => Padding(
//               padding: const EdgeInsets.symmetric(
//                   vertical: 0.0, horizontal: 0.0),
//               child: UsefulElements.backToMain(context, go_back: false,color: "white"),
//             ),
//           )
//           : Builder(
//               builder: (context) => IconButton(
//                 icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.white),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ),
//       title: Text(
//         getAppBarTitle(),
//         style: TextStyle(
//             fontSize: 16, color: MyTheme.white, fontWeight: FontWeight.bold),
//       ),
//       elevation: 0.0,
//       titleSpacing: 0,
//     );
//   }
//
//   String getAppBarTitle() {
//     String name = widget.parent_category_name == ""
//         ? (widget.is_top_category
//             ? AppLocalizations.of(context)!.top_categories_ucf
//             : AppLocalizations.of(context)!.categories_ucf)
//         : widget.parent_category_name;
//
//     return name;
//   }
//
//   buildCategoryList() {
//    var data = widget.is_top_category
//         ? CategoryRepository().getTopCategories()
//         : CategoryRepository()
//         .getCategories(parent_id: widget.parent_category_id);
//     return FutureBuilder(
//         future: data  ,
//         builder: (context,AsyncSnapshot<CategoryResponse> snapshot) {
//           if(snapshot.connectionState==ConnectionState.waiting){
//             return SingleChildScrollView(
//                 child:buildShimmer()
//             );
//           }
//           if (snapshot.hasError) {
//             //snapshot.hasError
//             print("category list error");
//             print(snapshot.error.toString());
//             return Container(
//               height: 10,
//             );
//           } else if (snapshot.hasData) {
//
//
//             return GridView.builder(
//               gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
//                 mainAxisSpacing: 14,
//                 crossAxisSpacing: 14,
//                 childAspectRatio: 0.7,
//                 crossAxisCount: 3,
//               ),
//
//               itemCount: snapshot.data!.categories!.length,
//               padding: EdgeInsets.only(left: 18,right: 18,bottom: widget.is_base_category?30:0),
//               scrollDirection: Axis.vertical,
//               physics: NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//
//                 return buildCategoryItemCard(snapshot.data, index);
//
//               },
//             );
//           } else {
//             return SingleChildScrollView(
//               child:buildShimmer()
//               /*
//               ListView.builder(
//                 itemCount: 10,
//                 scrollDirection: Axis.vertical,
//                 physics: NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.only(
//                         top: 4.0, bottom: 4.0, left: 16.0, right: 16.0),
//                     child: Row(
//                       children: [
//                         Shimmer.fromColors(
//                           baseColor: MyTheme.shimmer_base,
//                           highlightColor: MyTheme.shimmer_highlighted,
//                           child: Container(
//                             height: 60,
//                             width: 60,
//                             color: Colors.white,
//                           ),
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 16.0, bottom: 8.0),
//                               child: Shimmer.fromColors(
//                                 baseColor: MyTheme.shimmer_base,
//                                 highlightColor: MyTheme.shimmer_highlighted,
//                                 child: Container(
//                                   height: 20,
//                                   width: MediaQuery.of(context).size.width * .7,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 16.0),
//                               child: Shimmer.fromColors(
//                                 baseColor: MyTheme.shimmer_base,
//                                 highlightColor: MyTheme.shimmer_highlighted,
//                                 child: Container(
//                                   height: 20,
//                                   width: MediaQuery.of(context).size.width * .5,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),*/
//             );
//           }
//         });
//   }
//
//   Widget buildCategoryItemCard(categoryResponse, index) {
//
//     var itemWidth= ((DeviceInfo(context).width!-36)/3);
//     print(itemWidth);
//
//     return Container(
//       decoration: BoxDecorations.buildBoxDecoration_1(),
//       child: InkWell(
//         onTap: (){
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) {
//                 return CategoryProducts(
//                   category_id:
//                   categoryResponse.categories[index].id,
//                   category_name:
//                   categoryResponse.categories[index].name,
//                 );
//               },
//             ),
//           );
//         },
//         child: Container(
//           //padding: EdgeInsets.all(8),
//           //color: Colors.amber,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Container(
//                 constraints: BoxConstraints(maxHeight: itemWidth-28),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.only(
//                       topRight: Radius.circular(6), topLeft: Radius.circular(6)),
//                   child: FadeInImage.assetNetwork(
//                     placeholder: 'assets/placeholder.png',
//                     image: categoryResponse.categories[index].banner,
//                     fit: BoxFit.cover,
//                     height: itemWidth,
//                     width: DeviceInfo(context).width,
//                   ),
//                 ),
//               ),
//               Container(
//                 height: 60,
//                 //color: Colors.amber,
//                 alignment: Alignment.center,
//                 width: DeviceInfo(context).width,
//                 padding: const EdgeInsets.symmetric(horizontal: 14),
//                 child: Text(
//                   categoryResponse.categories[index].name,
//                   textAlign: TextAlign.center,
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 2,
//                   style: TextStyle(
//                       color: MyTheme.font_grey,
//                       fontSize: 10,
//                       height: 1.6,
//                       fontWeight: FontWeight.w600),
//
//                 ),
//               ),
//               Spacer()
//               /*Container(
//                 height: 80,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(32, 8, 8, 4),
//                       child: Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               if (categoryResponse
//                                       .categories[index].number_of_children >
//                                   0) {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) {
//                                       return CategoryList(
//                                         parent_category_id:
//                                             categoryResponse.categories[index].id,
//                                         parent_category_name:
//                                             categoryResponse.categories[index].name,
//                                       );
//                                     },
//                                   ),
//                                 );
//                               } else {
//                                 ToastComponent.showDialog(
//                                     AppLocalizations.of(context)
//                                         .category_list_screen_no_subcategories,
//                                     gravity: Toast.center,
//                                     duration: Toast.lengthLong);
//                               }
//                             },
//                             child: Text(
//                               AppLocalizations.of(context)
//                                   .category_list_screen_view_subcategories,
//                               textAlign: TextAlign.left,
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                               style: TextStyle(
//                                   color: categoryResponse.categories[index]
//                                               .number_of_children >
//                                           0
//                                       ? MyTheme.medium_grey
//                                       : MyTheme.light_grey,
//                                   decoration: TextDecoration.underline),
//                             ),
//                           ),
//                           Text(
//                             " | ",
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               color: MyTheme.medium_grey,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) {
//                                     return CategoryProducts(
//                                       category_id:
//                                           categoryResponse.categories[index].id,
//                                       category_name:
//                                           categoryResponse.categories[index].name,
//                                     );
//                                   },
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               AppLocalizations.of(context)
//                                   .category_list_screen_view_products,
//                               textAlign: TextAlign.left,
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                               style: TextStyle(
//                                   color: MyTheme.medium_grey,
//                                   decoration: TextDecoration.underline),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),*/
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Container buildBottomContainer() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//       ),
//
//       height: widget.is_base_category ? 0 : 80,
//       //color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Container(
//                 width: (MediaQuery.of(context).size.width - 32),
//                 height: 40,
//                 child: Btn.basic(
//                   minWidth: MediaQuery.of(context).size.width,
//                   color: Colors.orange,
//                   shape: RoundedRectangleBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(8.0))),
//                   child: Text(
//                     AppLocalizations.of(context)!
//                             .all_products_of_ucf +
//                         " " +
//                         widget.parent_category_name,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600),
//                   ),
//                   onPressed: () {
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) {
//                       return CategoryProducts(
//                         category_id: widget.parent_category_id,
//                         category_name: widget.parent_category_name,
//                       );
//                     }));
//                   },
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//
// Widget  buildShimmer(){
//     return  GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         mainAxisSpacing: 14,
//         crossAxisSpacing: 14,
//         childAspectRatio: 1,
//         crossAxisCount: 3,
//       ),
//
//       itemCount: 18,
//       padding: EdgeInsets.only(left: 18,right: 18,bottom: widget.is_base_category?30:0),
//       scrollDirection: Axis.vertical,
//       physics: NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemBuilder: (context, index) {
//         return Container(
//           decoration: BoxDecorations.buildBoxDecoration_1(),
//           child: ShimmerHelper().buildBasicShimmer(),
//         );
//       },
//     );
//
//   }
// }


import 'package:ecom_flutter/custom/box_decorations.dart';
import 'package:ecom_flutter/custom/btn.dart';
import 'package:ecom_flutter/custom/device_info.dart';
import 'package:ecom_flutter/custom/useful_elements.dart';
import 'package:ecom_flutter/data_model/category_response.dart';
import 'package:ecom_flutter/helpers/shimmer_helper.dart';
import 'package:ecom_flutter/presenter/bottom_appbar_index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecom_flutter/my_theme.dart';
import 'package:ecom_flutter/ui_sections/drawer.dart'; // Not used in snippet, but keep if needed elsewhere
import 'package:ecom_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart'; // Ensure this import is correct based on your pubspec
import 'package:ecom_flutter/screens/category_products.dart';
import 'package:ecom_flutter/repositories/category_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecom_flutter/app_config.dart';
import 'package:ecom_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryList extends StatefulWidget {
  CategoryList(
      {Key? key,
        this.parent_category_id = 0,
        this.parent_category_name = "",
        this.is_base_category = false,
        this.is_top_category = false,
        this.bottomAppbarIndex})
      : super(key: key);

  final int parent_category_id;
  final String parent_category_name;
  final bool is_base_category;
  final bool is_top_category;
  final BottomAppbarIndex? bottomAppbarIndex;

  @override
  _CategoryListState createState() => _CategoryListState();
}

// Add SingleTickerProviderStateMixin for TabController
class _CategoryListState extends State<CategoryList> with SingleTickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose TabController
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(children: [
        // Background stays the same
        Container(
          height: DeviceInfo(context).height! / 4,
          width: DeviceInfo(context).width,
          color: Colors.orange, // Using explicit color for clarity
          alignment: Alignment.topRight,
          child: Image.asset(
            "assets/background_1.png",
          ),
        ),
        Scaffold(
            key: _scaffoldKey, // Assign key if needed for drawer or other actions
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              child: buildAppBar(context),
              preferredSize: Size(DeviceInfo(context).width!, 50,),
            ),
            // Modify body to include Tabs
            body: buildBodyWithTabs() // Call the new method
        ),

        // Bottom container stays the same
        Align(
          alignment: Alignment.bottomCenter,
          child: widget.is_base_category || widget.is_top_category
              ? Container(
            height: 0,
          )
              : buildBottomContainer(),
        )
      ]),
    );
  }

  // New method to build the body structure with Tabs
  Widget buildBodyWithTabs() {
    return Column(
      children: [
        // TabBar Section
        Container(
          color: Colors.white, // Give TabBar a background
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.orange, // Color for selected tab label
            unselectedLabelColor: Colors.black, // Color for unselected tab labels
            indicatorColor: Colors.orange, // Color of the indicator line
            indicatorWeight: 3.0,
            tabs: [
              Tab(text: "Butcher"), // Adapt localization if needed
              Tab(text: "Grocery"), // Adapt localization if needed
            ],
          ),
        ),
        // TabBarView Section - Takes remaining space
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Content for Butcher Tab (currently same as default)
              buildCategoryGridScrollView(),
              // Content for Grocery Tab (currently same as default)
              buildCategoryGridScrollView(),
            ],
          ),
        ),
      ],
    );
  }


  // Renamed from buildBody - now returns only the scrollable grid part
  Widget buildCategoryGridScrollView() {
    return CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverList(
            delegate: SliverChildListDelegate([
              // Add some padding on top if needed, below the tabs
              SizedBox(height: 18),
              buildCategoryList(),
              // Adjust bottom padding calculation if needed
              Container(
                height: widget.is_base_category ? 60 : 90,
              )
            ]))
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: widget.is_base_category
          ? Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 0.0, horizontal: 0.0),
          child: UsefulElements.backToMain(context,
              go_back: false, color: "white"),
        ),
      )
          : Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        getAppBarTitle(),
        style: TextStyle(
            fontSize: 16, color: MyTheme.white, fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  String getAppBarTitle() {
    // Keep title logic the same, or adjust if needed based on tabs later
    String name = widget.parent_category_name == ""
        ? (widget.is_top_category
        ? AppLocalizations.of(context)!.top_categories_ucf
        : AppLocalizations.of(context)!.categories_ucf)
        : widget.parent_category_name;

    return name;
  }

  // buildCategoryList remains mostly the same, fetching data based on widget properties
  Widget buildCategoryList() {
    var data = widget.is_top_category
        ? CategoryRepository().getTopCategories()
        : CategoryRepository()
        .getCategories(parent_id: widget.parent_category_id);

    // IMPORTANT: In the future, you might want to fetch different data
    // based on the selected tab (_tabController.index).
    // For now, both tabs use the same 'data' future.

    return FutureBuilder(
        future: data  ,
        builder: (context,AsyncSnapshot<CategoryResponse> snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting){
            // Use the existing buildShimmer inside the sliver list padding area
            return buildShimmer();
          }
          if (snapshot.hasError) {
            print("category list error");
            print(snapshot.error.toString());
            return Container(
              height: 10, // Or show an error message
              alignment: Alignment.center,
              child: Text("ERROR OCCURED"), // Example error message
            );
          } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.categories != null) {
            // Check if categories list is empty
            if (snapshot.data!.categories!.isEmpty) {
              return Container(
                height: 100, // Adjust height as needed
                alignment: Alignment.center,
                child: Text("NO Category Found"), // Example message
              );
            }
            // GridView builder remains the same
            return GridView.builder(
              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.7, // Adjust aspect ratio if needed after adding tabs
                crossAxisCount: 3,
              ),

              itemCount: snapshot.data!.categories!.length,
              // Adjust padding as needed, especially left/right/bottom
              padding: EdgeInsets.only(left: 18,right: 18,bottom: widget.is_base_category?30:0),
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return buildCategoryItemCard(snapshot.data!, index); // Pass non-nullable data
              },
            );
          } else {
            // Also show shimmer when snapshot has no data but isn't waiting or error
            return buildShimmer();
          }
        });
  }

  // buildCategoryItemCard remains the same
  Widget buildCategoryItemCard(CategoryResponse categoryResponse, index) {

    var itemWidth= ((DeviceInfo(context).width!-36)/3);
    // print(itemWidth); // Keep for debugging if needed

    return Container(
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: InkWell(
        onTap: (){
          // Navigation logic remains the same
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                // Ensure categoryResponse.categories[index] is not null if possible
                var category = categoryResponse.categories![index];
                return CategoryProducts(
                  category_id: category.id!, // Use null assertion carefully or provide default
                  category_name: category.name!, // Use null assertion carefully or provide default
                );
              },
            ),
          );
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(maxHeight: itemWidth-28), // Adjust if needed
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6), topLeft: Radius.circular(6)),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    // Handle potential null banner URL
                    image: categoryResponse.categories![index].banner ?? 'assets/placeholder.png', // Provide a fallback
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/placeholder.png', // Fallback on error too
                          fit: BoxFit.cover,
                          height: itemWidth,
                          width: DeviceInfo(context).width);
                    },
                    fit: BoxFit.cover,
                    height: itemWidth,
                    width: DeviceInfo(context).width,
                  ),
                ),
              ),
              Container(
                height: 60, // Fixed height for text container
                alignment: Alignment.center,
                width: DeviceInfo(context).width,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  // Handle potential null name
                  categoryResponse.categories![index].name ?? AppLocalizations.of(context)!.categories_ucf,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 10,
                      height: 1.6,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Spacer() // Use Spacer to push text to the bottom if needed, but check layout
            ],
          ),
        ),
      ),
    );
  }


  // buildBottomContainer remains the same
  Container buildBottomContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 5,
            offset: Offset(0, -2), // changes position of shadow
          ),
        ],
      ),

      height: widget.is_base_category ? 0 : 80,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center, // Center content vertically if needed
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0), // Adjust padding if needed
              child: Container(
                // width: (MediaQuery.of(context).size.width - 32), // Full width button
                height: 40,
                child: Btn.basic(
                  minWidth: MediaQuery.of(context).size.width,
                  color: Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      const BorderRadius.all(Radius.circular(8.0))),
                  child: Text(
                    AppLocalizations.of(context)!
                        .all_products_of_ucf +
                        " " +
                        widget.parent_category_name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    // Navigation logic remains the same
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return CategoryProducts(
                            category_id: widget.parent_category_id,
                            category_name: widget.parent_category_name,
                          );
                        }));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  // buildShimmer remains the same
  Widget  buildShimmer(){
    return  GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        // childAspectRatio: 1, // Let's use the same aspect ratio as the actual items
        childAspectRatio: 0.7,
        crossAxisCount: 3,
      ),

      itemCount: 9, // Show fewer shimmer items (e.g., 3 rows)
      // Apply same padding as the actual grid for consistency
      padding: EdgeInsets.only(left: 18,right: 18,bottom: widget.is_base_category?30:0),
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecorations.buildBoxDecoration_1(),
          child: ShimmerHelper().buildBasicShimmer(),
        );
      },
    );
  }

  // Helper method for localization strings (add more as needed)
  AppLocalizations get S => AppLocalizations.of(context)!;

}

// Add these keys to your AppLocalizations file (e.g., app_en.arb):
/*
{
  "butcher_ucf": "Butcher",
  "grocery_ucf": "Grocery",
  "category_ucf": "Category",
  "no_categories_found": "No Categories Found",
  "common_error_occurred": "An error occurred. Please try again.",
  ... other strings
}
*/