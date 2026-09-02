import 'package:flutter_test/flutter_test.dart';
import 'package:tourism/mock/mock_location.dart';

void main() {
  test('test fetchAny', () {
    final location = MockLocation.fetchAny();
    expect(location.name, isNotEmpty);
    expect(location, isNotNull);
  });
}
