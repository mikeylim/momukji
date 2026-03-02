import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';

/// Screen displaying restaurants on an interactive Google Map.
///
/// Shows markers for all recommended restaurants and the user's location.
/// Includes a horizontal PageView carousel at the bottom for quick browsing.
/// Tapping a marker shows restaurant details in a bottom sheet.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Controller for the Google Map widget.
  GoogleMapController? _mapController;

  /// Set of markers displayed on the map.
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  /// Creates map markers for all restaurants and user location.
  ///
  /// Restaurant markers show name and rating in info window.
  /// User location marker is blue to distinguish from restaurants.
  void _buildMarkers() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final restaurants = provider.restaurants;

    // Create markers for each restaurant
    _markers = restaurants.map((restaurant) {
      return Marker(
        markerId: MarkerId(restaurant.id),
        position: LatLng(restaurant.latitude, restaurant.longitude),
        infoWindow: InfoWindow(
          title: restaurant.name,
          snippet: restaurant.rating != null
              ? '${restaurant.rating} - ${restaurant.typesDisplay}'
              : restaurant.typesDisplay,
        ),
        onTap: () {
          provider.selectRestaurant(restaurant);
          _showRestaurantBottomSheet(context, restaurant);
        },
      );
    }).toSet();

    // Add current location marker if available
    if (provider.currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            provider.currentPosition!.latitude,
            provider.currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isKorean = provider.locale.languageCode == 'ko';

        // Default to Seoul if no location available
        final initialPosition = provider.currentPosition != null
            ? LatLng(
                provider.currentPosition!.latitude,
                provider.currentPosition!.longitude,
              )
            : const LatLng(37.5665, 126.9780);

        return Scaffold(
          appBar: AppBar(
            title: Text(isKorean ? '지도' : 'Map'),
            actions: [
              // Button to recenter on user location
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  if (provider.currentPosition != null && _mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(
                          provider.currentPosition!.latitude,
                          provider.currentPosition!.longitude,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // Google Map widget
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialPosition,
                  zoom: 14,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false, // Using custom button in AppBar
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),

              // Restaurant carousel at bottom
              if (provider.restaurants.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    height: 150,
                    child: PageView.builder(
                      itemCount: provider.restaurants.length,
                      controller: PageController(viewportFraction: 0.9),
                      onPageChanged: (index) {
                        // Pan map to selected restaurant
                        final restaurant = provider.restaurants[index];
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(restaurant.latitude, restaurant.longitude),
                          ),
                        );
                      },
                      itemBuilder: (context, index) {
                        final restaurant = provider.restaurants[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: RestaurantCard(
                            restaurant: restaurant,
                            compact: true,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a bottom sheet with full restaurant details.
  void _showRestaurantBottomSheet(BuildContext context, Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantCard(restaurant: restaurant),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
