import 'package:flutter/material.dart';
import 'model/location.dart';
import 'styles.dart';
import 'common.dart';
import 'dart:async';

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                CommonWidget.renderProgressBar(_loading) +
                _renderBody(context, location),
          ),
        ),
      ),
    );
  }

  Future loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        Timer(Duration(milliseconds: 8000), () async {
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

  //Widget renderProgressBar() {
  //  return (_loading
  //       ? LinearProgressIndicator(
  //           value: null,
  //           backgroundColor: Colors.grey,
  //           valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
  //         )
  //       : Container());
  //}

  List<Widget> _renderBody(BuildContext context, Location location) {
    var result = <Widget>[];
    result.add(_bannerImage(location.image, 170.0));
    result.addAll(_renderFacts(context, location));
    return result;
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
      padding: EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 10.0),
      child: Text(text, textAlign: TextAlign.left, style: Styles.headerLarge),
    );
  }

  Widget _sectionText(String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
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
}

extension on Widget {
  List<Widget> operator +(List<Widget> other) {
    return ([this] + other);
  }
}
