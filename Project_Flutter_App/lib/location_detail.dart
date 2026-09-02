import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/location.dart';
import 'component/location_tile.dart';
import 'styles.dart';
import 'common.dart';
import 'dart:async';

const bannerImageHeight = 300.0;
const bodyVerticalPadding = 20.0;
const footerHeight = 100.0;

class LocationDetail extends StatefulWidget {
  final int locationID;
  const LocationDetail({super.key, required this.locationID});
  @override
  State<LocationDetail> createState() => _LocationDetailState();
}

class _LocationDetailState extends State<LocationDetail> {
  Location location = Location.blank();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(location.name, style: Styles.navBarTitle)),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: Stack(
          children: [
            _renderBody(context, location),
            _renderFooter(context, location),
            CommonWidget.renderProgressBar(_loading),
          ],
        ),
      ),
    );
  }

  Future loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        Timer(Duration(milliseconds: 3000), () async {
          final location = await Location.fetchByID(widget.locationID);
          if (mounted) {
            setState(() {
              this.location = location!;
              _loading = false;
            });
          }
        });
      });
    }
  }

  Widget _renderBody(BuildContext context, Location location) {
    var result = <Widget>[];
    result.add(_bannerImage(location.image, bannerImageHeight));
    result.add(_renderHeader());
    result.addAll(_renderFacts(context, location));
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: result,
      ),
    );
  }

  Widget _renderHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: bodyVerticalPadding,
        horizontal: Styles.horizontalPaddingDefault,
      ),
      child: LocationTile(location: location, darkTheme: false),
    );
  }

  Widget _renderFooter(BuildContext context, Location location) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white54),
          height: footerHeight,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
            child: _renderBookButton(),
          ),
        ),
      ],
    );
  }

  List<Widget> _renderFacts(BuildContext context, Location location) {
    var result = <Widget>[];
    for (int i = 0; i < (location.facts ?? []).length; i++) {
      result.add(_sectionTitle(location.facts![i].title));
      result.add(_sectionText(location.facts![i].text));
    }
    return result;
  }

  Widget _sectionTitle(String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Styles.horizontalPaddingDefault,
        25.0,
        Styles.horizontalPaddingDefault,
        10.0,
      ),
      child: Text(text, textAlign: TextAlign.left, style: Styles.headerLarge),
    );
  }

  Widget _sectionText(String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Styles.horizontalPaddingDefault,
        15.0,
        Styles.horizontalPaddingDefault,
        15.0,
      ),
      child: Text(text, style: Styles.textDefault),
    );
  }

  Widget _bannerImage(String image, double height) {
    if (image.isEmpty) {
      return Container();
    }

    try {
      return Container(
        constraints: BoxConstraints.tightFor(height: height),
        child: Image.asset(image, fit: BoxFit.fitWidth),
      );
    } catch (e) {
      debugPrint("could not load image $image");
      return Container();
    }
  }

  Widget _renderBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Styles.accentColor,
          foregroundColor: Colors.white,
        ),
        onPressed: onBookNowPress,
        child: Text("Book this location", style: Styles.textCTAButton),
      ),
    );
  }

  void onBookNowPress() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Book Now"),
          content: Text("Are you sure you want to book this location?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onBookForm();
              },
              child: Text("Book Now"),
            ),
          ],
        );
      },
    );
  }

  void onBookForm() async {
    const url = 'https://forms.gle/f1nC8XFkdqeCSXGC7';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not launch $url');
    }
  }
}
