import '../model/location.dart';
import '../model/location_fact.dart';

mixin MockLocation implements Location {
  static final List<Location> items = [
    Location(
      id: 1,
      name: 'Arashiyama Bamboo Grove',
      image: 'assets/images/bamboo-grove-arashiyama.jpg',
      user_itnerary_summary: "DAY 1 1:00 PM - 12:00 AM",
      package_name: "Standard",
      facts: <LocationFact>[
        LocationFact(
          title: 'Summary',
          text:
              'While we could go on about the ethereal glow and seemingly endless heights of this bamboo grove on the outskirts of Kyoto, the sight\'s pleasures extend beyond the visual realm',
        ),
        LocationFact(
          title: 'How to Get There',
          text:
              'Kyoto airport, with several terminals, is located 16 kilometres south of the city and is also known as Kyoto. Kyoto can also be reached by transport links from other regional airports.',
        ),
      ],
    ),
    Location(
      id: 2,
      name: 'Mount Fuji',
      image: 'assets/images/mount-fuji.jpg',
      user_itnerary_summary: "DAY 1 1:00 PM - 12:00 AM",
      package_name: "Standard",
      facts: <LocationFact>[
        LocationFact(
          title: 'Summary',
          text:
              'While we could go on about the ethereal glow and seemingly endless heights of this bamboo grove on the outskirts of Kyoto, the sight\'s pleasures extend beyond the visual realm',
        ),
        LocationFact(
          title: 'How to Get There',
          text:
              'Kyoto airport, with several terminals, is located 16 kilometres south of the city and is also known as Kyoto. Kyoto can also be reached by transport links from other regional airports.',
        ),
      ],
    ),
    Location(
      id: 3,
      name: 'Kiyomizu-dera',
      image: 'assets/images/kiyomizu-dera.jpg',
      user_itnerary_summary: "DAY 1 1:00 PM - 12:00 AM",
      package_name: "Standard",
      facts: <LocationFact>[
        LocationFact(
          title: 'Summary',
          text:
              'While we could go on about the ethereal glow and seemingly endless heights of this bamboo grove on the outskirts of Kyoto, the sight\'s pleasures extend beyond the visual realm',
        ),
        LocationFact(
          title: 'How to Get There',
          text:
              'Kyoto airport, with several terminals, is located 16 kilometres south of the city and is also known as Kyoto. Kyoto can also be reached by transport links from other regional airports.',
        ),
      ],
    ),
    Location(
      id: 4,
      name: 'Kinkaku-ji',
      image: 'assets/images/kinkaku-ji.jpg',
      user_itnerary_summary: "DAY 1 1:00 PM - 12:00 AM",
      package_name: "Standard",
      facts: <LocationFact>[
        LocationFact(
          title: 'Summary',
          text:
              'While we could go on about the ethereal glow and seemingly endless heights of this bamboo grove on the outskirts of Kyoto, the sight\'s pleasures extend beyond the visual realm',
        ),
        LocationFact(
          title: 'How to Get There',
          text:
              'Kyoto airport, with several terminals, is located 16 kilometres south of the city and is also known as Kyoto. Kyoto can also be reached by transport links from other regional airports.',
        ),
      ],
    ),
    Location(
      id: 5,
      name: 'Odaiba',
      image: 'assets/images/Odaiba.jpg',
      user_itnerary_summary: "DAY 1 1:00 PM - 12:00 AM",
      package_name: "Standard",
      facts: <LocationFact>[
        LocationFact(
          title: 'Summary',
          text:
              'While we could go on about the ethereal glow and seemingly endless heights of this bamboo grove on the outskirts of Kyoto, the sight\'s pleasures extend beyond the visual realm',
        ),
        LocationFact(
          title: 'How to Get There',
          text:
              'Kyoto airport, with several terminals, is located 16 kilometres south of the city and is also known as Kyoto. Kyoto can also be reached by transport links from other regional airports.',
        ),
      ],
    ),
  ];

  static Location fetchAny() {
    return MockLocation.items[0];
  }

  static List<Location> fetchAll() {
    return MockLocation.items;
  }

  static Location fetch(int index) {
    return MockLocation.items[index];
  }

  static Location fetchByID(int id) {
    return MockLocation.items.firstWhere((location) => location.id == id);
  }
}
