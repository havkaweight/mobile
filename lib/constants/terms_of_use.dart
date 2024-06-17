import 'package:flutter/cupertino.dart';

class TermsOfUse extends StatelessWidget {
  @override
  Widget build(context) {
    return Column(children: [
      Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Text(
              "Terms of Use",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            Text(
              "Last modified: 02.04.2024",
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              "1. Introduction",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          Container(
            child: Text(
                "These Terms of Use (\"Terms\") govern your access to and use of the Havka mobile application (the \"App\"). By downloading, installing, or using the App, you agree to be bound by these Terms. If you disagree with any part of these Terms, then you may not access or use the App."),
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              "2. User Accounts",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          Container(
            child: Text(
                "You may be required to create an account to access certain features of the App. You are responsible for maintaining the confidentiality of your account information, including your password. You agree to accept responsibility for all activities that occur under your account."),
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              "3. User Data",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          Container(
            child: Text("The App collects certain user data, including:"),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("- First Name"),
                Text("- Last Name"),
                Text("- Date of Birth"),
                Text("- Weight"),
                Text("- Height"),
              ],
            ),
          ),
          Container(
            child: Text(
                "This data is used to provide personalized calorie counting and may be used for other features as described in the Privacy Policy."),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              "4. Disclaimers",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          Container(
            child: Text(
                "The App is provided \"as is\" and without warranties of any kind, whether express or implied. The information provided by the App is for informational purposes only and should not be construed as medical advice. You should always consult with a healthcare professional before making any changes to your diet or exercise routine."),
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              "5. Limitation of Liability",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          Container(
            child: Text(
                "To the fullest extent permitted by law, the developers of the App will not be liable for any damages arising out of or related to your use of the App."),
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              "6. Termination",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          Container(
            child: Text(
                "We may terminate your access to the App for any reason, at any time, without notice."),
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              "7. Governing Law",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          Container(
            child: Text(
                "These Terms will be governed by and construed in accordance with the laws of Cyprus Republic."),
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              "8. Entire Agreement",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          Container(
            child: Text(
                "These Terms constitute the entire agreement between you and us regarding your use of the App."),
          )
        ],
      ),
    ]);
  }
}
