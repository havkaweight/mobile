import 'package:flutter/cupertino.dart';

class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              Text(
                "Privacy Policy",
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
              child: Text("This Privacy Policy describes how we collect, use, and disclose your information when you use the App."),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                "2. Information We Collect",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              child: Text("We collect the following information:"),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text("Personal Information: We collect your weight, height, date of birth, first and last name to create a personalized experience and provide accurate calorie counting."),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text("Usage Data: We may collect information about how you use the App, such as the features you access and the data you enter."),
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                "3. How We Use Your Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              child: Text("We use your information to:"),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("- Provide and improve the App"),
                  Text("- Personalize your experience"),
                  Text("- Analyze how the App is used"),
                  Text("- Communicate with you"),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                "4. Sharing Your Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              child: Text("We will not share your personal information with third parties without your consent, except in the following cases:"),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("- To comply with legal obligations"),
                  Text("- To protect the rights and safety of ourselves or others"),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                "5. Data Security",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              child: Text("We take reasonable steps to protect your information from unauthorized access, disclosure, alteration, or destruction. However, no internet transmission or electronic storage is completely secure."),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                "6. Your Choices",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              child: Text("You have the right to access, update, or delete your personal information. You can also opt out of receiving communications from us."),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                "7. Children's Privacy",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              child: Text("The App is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13."),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                "8. Changes to This Privacy Policy",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              child: Text("We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on the App."),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                "9. Contact Us",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              child: Text("If you have any questions about this Privacy Policy, please contact us at paul23093@yandex.ru."),
            )
          ],
        ),
      ]
    );
  }
}