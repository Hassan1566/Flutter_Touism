import 'package:flutter/material.dart';
import 'model/location.dart';
import 'styles.dart';
import 'location_detail.dart';
import 'component/location_tile.dart';

const listitemheight = 245.0;

class LocationList extends StatefulWidget {
  const LocationList({super.key});

  @override
  State<LocationList> createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  List<Location> locations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final fetchedLocations = await Location.fetchAll();
    setState(() {
      locations = fetchedLocations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Locations", style: Styles.navBarTitle)),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(children: [Expanded(child: _listview())]),
      ),
    );
  }

  Widget _listview() {
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return GestureDetector(
          onTap: () => _navigatetolocationdetail(context, location.id),
          child: SizedBox(
            height: listitemheight,
            child: Stack(
              children: [
                _imageTile(
                  location.image,
                  listitemheight,
                  MediaQuery.of(context).size.width,
                ),
                _tileFooter(location),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigatetolocationdetail(BuildContext context, int locationID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return LocationDetail(locationID: locationID);
        },
      ),
    );
  }

  Widget _imageTile(String image, double height, double width) {
    if (image.isEmpty) {
      return SizedBox(height: height, width: width);
    }

    try {
      return SizedBox(
        height: height,
        width: width,
        child: Image.asset(image, fit: BoxFit.cover),
      );
    } catch (e) {
      debugPrint("could not load image $image");
      return SizedBox(height: height, width: width);
    }
  }

  Widget _tileFooter(Location location) {
    final info = LocationTile(location: location, darkTheme: true);
    final overlay = Container(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: Styles.horizontalPaddingDefault,
      ),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
      child: info,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [overlay],
    );
  }

  Widget _itemTitle(Location location) {
    return Text(location.name, style: Styles.textDefault);
  }
}
