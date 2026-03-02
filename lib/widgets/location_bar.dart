import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class LocationBar extends StatelessWidget {
  const LocationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isKorean = provider.locale.languageCode == 'ko';
        final hasLocation = provider.currentPosition != null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: InkWell(
            onTap: () => _showLocationDialog(context, provider, isKorean),
            child: Row(
              children: [
                Icon(
                  hasLocation ? Icons.location_on : Icons.location_off,
                  color: hasLocation
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasLocation
                        ? (provider.currentAddress ??
                            '${provider.currentPosition!.latitude.toStringAsFixed(4)}, ${provider.currentPosition!.longitude.toStringAsFixed(4)}')
                        : (isKorean ? '위치 설정하기' : 'Set location'),
                    style: TextStyle(
                      color: hasLocation ? Colors.black87 : Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLocationDialog(
    BuildContext context,
    AppProvider provider,
    bool isKorean,
  ) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isKorean ? '위치 설정' : 'Set Location',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: Text(isKorean ? '현재 위치 사용' : 'Use Current Location'),
              onTap: () {
                Navigator.pop(context);
                provider.refreshLocation();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              tileColor: Colors.grey[100],
            ),
            const SizedBox(height: 16),
            Text(
              isKorean ? '또는 주소 검색' : 'Or search for an address',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: isKorean ? '주소 입력...' : 'Enter address...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      Navigator.pop(context);
                      provider.searchLocationByAddress(controller.text);
                    }
                  },
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(context);
                  provider.searchLocationByAddress(value);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
