import 'dart:convert';
import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/model/data_items.dart';
import 'package:havka/model/fridge_data_model.dart';
import 'package:havka/model/product.dart';
import 'package:havka/model/product_amount.dart';
import 'package:havka/model/user_consumption_item.dart';
import 'package:havka/model/user_fridge_item.dart';
import 'package:havka/ui/screens/fridge_adjustment_screen.dart';
import 'package:havka/ui/screens/havka_barcode_scanner.dart';
import 'package:havka/ui/screens/havka_receipt_scanner.dart';
import 'package:havka/ui/screens/products_screen.dart';
import 'package:havka/ui/screens/scrolling_behavior.dart';
import 'package:havka/ui/widgets/fridgeitem.dart';
import 'package:havka/ui/widgets/holder.dart';
import 'package:havka/ui/widgets/modal_scale.dart';
import 'package:havka/ui/widgets/screen_header.dart';
import 'package:havka/ui/widgets/shimmer.dart';
import 'package:havka/ui/widgets/stack_bar_chart.dart';
import 'package:havka/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/utils.dart';
import '../../model/fridge.dart';
import 'authorization.dart';


class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: AlignmentDirectional.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("This link is unreachable for you :-("),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.05))
                  ),
                  onPressed: () => context.go("/fridge"),
                  child: Text("Open my Fridge"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
