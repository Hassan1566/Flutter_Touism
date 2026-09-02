// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  image: json['image'] as String? ?? '',
  facts: (json['facts'] as List<dynamic>?)
      ?.map((e) => LocationFact.fromJson(e as Map<String, dynamic>))
      .toList(),
  user_itnerary_summary: json['user_itnerary_summary'] as String? ?? '',
  package_name: json['package_name'] as String? ?? '',
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image': instance.image,
  'facts': instance.facts,
  'user_itnerary_summary': instance.user_itnerary_summary,
  'package_name': instance.package_name,
};
