import 'package:flutter_test/flutter_test.dart';

import 'package:tourism/model/location.dart';

void main() {
  test('test /locations and /locations/:id', () async {
    final locations = await Location.fetchAll();
    for (var location in locations) {
      expect(location.id, greaterThan(0));
      expect(location.name, hasLength(greaterThan(0)));
      expect(location.image, hasLength(greaterThan(0)));

      final fetchedLocation = await Location.fetchByID(location.id);
      expect(fetchedLocation!.name, equals(location.name));
      expect(fetchedLocation.image, equals(location.image));
    }
  });
}
