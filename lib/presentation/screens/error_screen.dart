import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


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
