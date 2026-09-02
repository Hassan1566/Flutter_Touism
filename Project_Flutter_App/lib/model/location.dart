import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'location_fact.dart';
import '../endpoint.dart';
import 'dart:convert';

part 'location.g.dart';

@JsonSerializable()
class Location {
  final int id;
  final String name;
  @JsonKey(name: 'image')
  final String image;
  final List<LocationFact>? facts;
  @JsonKey(name: 'use_itnerary_summary')
  // ignore: non_constant_identifier_names
  final String user_itnerary_summary;
  @JsonKey(name: 'package_name')
  // ignore: non_constant_identifier_names
  final String package_name;
  Location({
    required this.id,
    required this.name,
    required this.image,
    required this.facts,
    required this.user_itnerary_summary,
    required this.package_name,
  });

  Location.blank()
    : id = 0,
      name = '',
      image = '',
      facts = [],
      user_itnerary_summary = '',
      package_name = '';

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  static Future<List<Location>> fetchAll() async {
    var uri = Endpoint.uri('/location.json', queryParameters: {});

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw (resp.body);
    }
    List<Location> list = <Location>[];
    for (var jsonItem in json.decode(resp.body)) {
      list.add(Location.fromJson(jsonItem));
    }
    return list;
  }

  static Future<Location?> fetchByID(int id) async {
    final locations = await fetchAll();
    return locations.firstWhereOrNull((location) => location.id == id);
  }
}
