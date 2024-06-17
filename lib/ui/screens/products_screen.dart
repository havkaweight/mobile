import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/model/fridge.dart';
import 'package:havka/model/fridge_data_model.dart';
import 'package:havka/model/product.dart';
import 'package:havka/ui/screens/product_adjustment_screen.dart';
import 'package:havka/ui/widgets/progress_indicator.dart';
import 'package:havka/ui/widgets/rounded_textfield.dart';
import 'package:havka/ui/widgets/search_textfield.dart';
import 'package:provider/provider.dart';

import '../../constants/icons.dart';
import '../widgets/holder.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  final ApiRoutes _apiRoutes = ApiRoutes();
  final _searchController = TextEditingController();

  // late final AnimationController _swipingController;

  double minChildSize = 0.5;
  double maxChildSize = 0.85;

  final ScrollController _listScrollController = ScrollController();
  late Offset _appBarOffset;
  late double _appBarBlurRadius;

  @override
  void initState() {
    super.initState();

    _appBarOffset = Offset.zero;
    _appBarBlurRadius = 0.0;

    _listScrollController.addListener(() {
      if (_listScrollController.position.pixels <= 0.0) {
        setState(() {
          _appBarOffset = Offset.zero;
          _appBarBlurRadius = 0.0;
        });
      } else if (_listScrollController.position.pixels > 5.0) {
        setState(() {
          _appBarOffset = Offset(0.0, 2.0);
          _appBarBlurRadius = 1.0;
        });
      } else {
        setState(() {
          _appBarOffset = Offset(0.0, _listScrollController.position.pixels / 2.5);
          _appBarBlurRadius = _listScrollController.position.pixels / 5.0;
        });
      }
    });

    // _swipingController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 200),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: maxChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        scrollController.addListener(() {
          if (scrollController.position.pixels <= 0.0) {
            setState(() {
              _appBarOffset = Offset.zero;
              _appBarBlurRadius = 0.0;
            });
          } else if (scrollController.position.pixels > 5.0) {
            setState(() {
              _appBarOffset = Offset(0.0, 2.0);
              _appBarBlurRadius = 1.0;
            });
          } else {
            setState(() {
              _appBarOffset = Offset(0.0, scrollController.position.pixels / 2.5);
              _appBarBlurRadius = scrollController.position.pixels / 5.0;
            });
          }
        });
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), // Adjust the radius as needed
              topRight: Radius.circular(20.0),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: HavkaColors.cream,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: _appBarOffset,
                        blurRadius: _appBarBlurRadius,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Holder(
                        height: 30,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                        height: 55,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SearchTextField(
                                hintText: "Search food",
                                controller: _searchController,
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                            Consumer<FridgeDataModel>(
                                builder: (context, fridgeDataModel, _) {
                                  return IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.black.withOpacity(0.05)),
                                    ),
                                    onPressed: () async {
                                      final Product? product = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ProductAdjustmentScreen(),
                                        ),
                                      );
                                      if (product == null) {
                                        context.pop();
                                      } else {
                                        context.pop(product);
                                      }
                                    },
                                  );
                                }
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.85 - 30 - 55,
                    child: FutureBuilder<List<Product>>(
                            future: _searchController.text.isEmpty
                            ? _apiRoutes.getProductsList()
                            : _apiRoutes.getProductsBySearchingRequest(_searchController.text),
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<List<Product>> snapshot,
                            ) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 40.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 8.0),
                                          child: Icon(
                                            Icons.sick_outlined,
                                            size: 50,
                                            color: Colors.black.withOpacity(0.4),
                                          ),
                                        ),
                                        Text(
                                          "Failed to load products",
                                          style: TextStyle(
                                            color: Colors.black.withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (!snapshot.hasData) {
                                return ShaderMask(
                                  shaderCallback: (rect) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black,
                                        Colors.transparent,
                                      ],
                                      stops: [0, 1],
                                    ).createShader(
                                      Rect.fromLTWH(
                                        0,
                                        0,
                                        rect.width,
                                        rect.height,
                                      ),
                                    );
                                  },
                                  blendMode: BlendMode.dstIn,
                                  child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: (MediaQuery.of(context).size.height * 0.85 - 30 - 55) ~/ 80,
                                    itemBuilder: (BuildContext context, index) {
                                      return ListTile(
                                        tileColor: Colors.transparent,
                                        leading: Container(
                                          width: 50.0,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.05),
                                            image: null,
                                            borderRadius: BorderRadius.circular(50.0),
                                          ),
                                          child: const Icon(HavkaIcons.bowl,
                                              color: HavkaColors.energy, size: 24),
                                        ),
                                        title: Container(
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                        ),
                                        subtitle: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                                return Center(
                                  child: HavkaProgressIndicator(),
                                );
                              }
                              if (snapshot.hasData) {
                                snapshot.data!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                                return NotificationListener<DraggableScrollableNotification>(
                                  // onNotification: (notification) {
                                  //   return notification.extent > 0.5;
                                  // },
                                  child: Scrollbar(
                                    controller: scrollController,
                                    child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (BuildContext context, index) {
                                        final Product product = snapshot.data![index];
                                        return ListTile(
                                          tileColor: Colors.transparent,
                                          leading: Container(
                                            width: 50.0,
                                            height: 50.0,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.05),
                                              image: product.images != null
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                        product.images!.small!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                              borderRadius: BorderRadius.circular(50.0),
                                            ),
                                            child: const Icon(HavkaIcons.bowl,
                                                color: HavkaColors.energy, size: 24),
                                          ),
                                          title: Text(
                                            product.name!,
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge!
                                                  .fontSize,
                                            ),
                                          ),
                                          subtitle: Text(
                                            product.brand?.name ?? "",
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .fontSize,
                                            ),
                                          ),
                                          trailing: Container(
                                            alignment: AlignmentDirectional.centerEnd,
                                            width: 100,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Consumer<FridgeDataModel>(
                                                  builder: (context, fridgeDataModel, _) {
                                                    return IconButton(
                                                      onPressed: () async {
                                                        final Product? p = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductAdjustmentScreen(product: product,)));
                                                        if(p != null) {
                                                          context.pop(p);
                                                        } else {
                                                          context.pop();
                                                        }
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.05))
                                                      ),
                                                      icon: Icon(Icons.edit),
                                                    );
                                                  }
                                                ),
                                                IconButton(
                                                  onPressed: () => Navigator.pop(context, product),
                                                  style: ButtonStyle(
                                                      backgroundColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.05))
                                                  ),
                                                  icon: Icon(Icons.add),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                              return const Center(
                                  child: Text('Error internet connection'));
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Future _addToFridge(UserFridge userFridge, Product product) async {
    context.pop();
    await ApiRoutes().addFridgeItem(userFridge, product);
  }

}
