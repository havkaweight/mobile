import 'package:flutter/material.dart';
import '../../data/models/device/user_device_model.dart';
import '/presentation/screens/profile_screen.dart';
import '/presentation/widgets/progress_indicator.dart';
import '/presentation/widgets/rounded_button.dart';
import '/presentation/widgets/screen_header.dart';

class UserDevicesScreen extends StatefulWidget {
  @override
  _UserDevicesScreenState createState() => _UserDevicesScreenState();
}

class _UserDevicesScreenState extends State<UserDevicesScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future<bool>(() {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        return true;
      }),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const ScreenHeader(text: 'My devices'),
              RoundedButton(
                text: 'Add device',
                onPressed: () {},
              ),
              FutureBuilder<List<UserDevice>>(
                future: _apiRoutes.getUserDevicesList(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<UserDevice>> snapshot,
                ) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: const HavkaProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.data.runtimeType == List) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, index) {
                          final UserDevice userDevice = snapshot.data![index];
                          return ListTile(
                            title: Text(userDevice.userDeviceName!),
                            subtitle: Text(userDevice.deviceId.toString()),
                          );
                        },
                      ),
                    );
                  }
                  return const Text('No data :-(');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
