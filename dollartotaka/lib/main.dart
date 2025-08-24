import 'package:flutter/material.dart';

void main() {
  runApp(const TravelGuideApp());
}

/// Single-file Travel Guide App (DartPad-friendly, no plugins/assets)
class TravelGuideApp extends StatelessWidget {
  const TravelGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

/// ---- Data Model ----
class Destination {
  final String id;
  final String name;
  final String country;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  String get coords => '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}

/// ---- In-memory sample data (network images work in DartPad) ----
const List<Destination> kDestinations = [
  Destination(
    id: '1',
    name: 'Eiffel Tower',
    country: 'France',
    description:
        'An iron lattice tower in Paris. One of the world’s most recognizable landmarks and a must-see for first-time visitors.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/a/a8/Tour_Eiffel_Wikimedia_Commons.jpg',
    latitude: 48.8584,
    longitude: 2.2945,
  ),
  Destination(
    id: '2',
    name: 'Great Wall of China',
    country: 'China',
    description:
        'Ancient series of walls and fortifications. Offers breathtaking views and rich history across northern China.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/10/20090529_Great_Wall_8185.jpg',
    latitude: 40.4319,
    longitude: 116.5704,
  ),
  Destination(
    id: '3',
    name: 'Santorini',
    country: 'Greece',
    description:
        'Famous for whitewashed villages, blue-domed churches, sunsets over the caldera, and crystal-clear Aegean waters.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/8/81/Santorini-sunset.jpg',
    latitude: 36.3932,
    longitude: 25.4615,
  ),
  Destination(
    id: '4',
    name: 'Machu Picchu',
    country: 'Peru',
    description:
        'A 15th-century Inca citadel in the Andes. A blend of mystery, engineering marvel, and stunning mountain scenery.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/eb/Machu_Picchu%2C_Peru.jpg',
    latitude: -13.1631,
    longitude: -72.5450,
  ),
  Destination(
    id: '5',
    name: 'Cox’s Bazar',
    country: 'Bangladesh',
    description:
        'Home to one of the longest natural sea beaches in the world. Golden sands, gentle surf, and vibrant local life.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/6c/Cox%27s_Bazar_sea_beach.jpg',
    latitude: 21.4272,
    longitude: 92.0058,
  ),
];

/// ---- Home + Search + Favorites ----
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  final Set<String> _favoriteIds = <String>{};

  List<Destination> get _filtered {
    if (_query.trim().isEmpty) return kDestinations;
    final q = _query.toLowerCase();
    return kDestinations.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.country.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q);
    }).toList();
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Guide'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FavoritesScreen(
                    favorites: kDestinations.where((d) => _favoriteIds.contains(d.id)).toList(),
                    onRemove: (id) => _toggleFavorite(id),
                  ),
                ),
              );
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SearchField(
              hint: 'Search places, countries, highlights…',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      body: results.isEmpty
          ? const _EmptyState(message: 'No destinations found.\nTry a different search.')
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final dest = results[index];
                final isFav = _favoriteIds.contains(dest.id);
                return DestinationCard(
                  destination: dest,
                  isFavorite: isFav,
                  onFavorite: () => _toggleFavorite(dest.id),
                  onOpen: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DestinationDetailScreen(
                          destination: dest,
                          isFavorite: isFav,
                          onToggleFavorite: () => _toggleFavorite(dest.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

/// ---- Destination Card ----
class DestinationCard extends StatelessWidget {
  final Destination destination;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.isFavorite,
    required this.onFavorite,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'img_${destination.id}',
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  destination.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFFE0E0E0),
                    child: Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(destination.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(destination.country),
              trailing: IconButton(
                tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                onPressed: onFavorite,
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                destination.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// ---- Detail Screen ----
class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destination.name),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: onToggleFavorite,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coordinates: ${destination.coords}\n(Map plugins aren’t allowed in DartPad)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.map),
        label: const Text('View on Map'),
      ),
      body: ListView(
        children: [
          Hero(
            tag: 'img_${destination.id}',
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                destination.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFE0E0E0),
                  child: Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '${destination.name}, ${destination.country}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              destination.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: const Text('Coordinates'),
            subtitle: Text(destination.coords),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ---- Favorites Screen ----
class FavoritesScreen extends StatelessWidget {
  final List<Destination> favorites;
  final void Function(String id) onRemove;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const _EmptyState(message: 'No favorites yet.\nTap the heart icon to save places.')
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final dest = favorites[index];
                return Card(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(dest.imageUrl),
                      onBackgroundImageError: (_, __) {},
                    ),
                    title: Text(dest.name),
                    subtitle: Text(dest.country),
                    trailing: IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => onRemove(dest.id),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DestinationDetailScreen(
                            destination: dest,
                            isFavorite: true,
                            onToggleFavorite: () => onRemove(dest.id),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

/// ---- Reusable Widgets ----
class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
