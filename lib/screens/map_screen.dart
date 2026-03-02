import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  void _buildMarkers() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final restaurants = provider.restaurants;

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

    // Add current location marker
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
        final initialPosition = provider.currentPosition != null
            ? LatLng(
                provider.currentPosition!.latitude,
                provider.currentPosition!.longitude,
              )
            : const LatLng(37.5665, 126.9780); // Seoul as default

        return Scaffold(
          appBar: AppBar(
            title: Text(isKorean ? '지도' : 'Map'),
            actions: [
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
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialPosition,
                  zoom: 14,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
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
