import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../notes/presentation/controller/cart_controller.dart';

class LocationHeader extends StatelessWidget {
  final String selectedUniversity;
  final List<String> universities;
  final ValueChanged<String?> onUniversityChanged;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final VoidCallback? onCartTap;

  const LocationHeader({
    super.key,
    required this.selectedUniversity,
    required this.universities,
    required this.onUniversityChanged,
    required this.onSearchTap,
    required this.onNotificationTap,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    const iconColor = AppColors.muted;
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 20, color: iconColor),
        const SizedBox(width: 4),
        Expanded(
          child: DropdownButton<String>(
            value: selectedUniversity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: iconColor),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            items: universities.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: textColor)),
              );
            }).toList(),
            focusColor: Colors.transparent,
            borderRadius: BorderRadius.circular(12), 
            onChanged: onUniversityChanged,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search, size: 24, color: iconColor),
          onPressed: onSearchTap,
        ),
        // Cart icon with badge
        Consumer<CartController>(
          builder: (context, cart, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, size: 24, color: iconColor),
                  onPressed: onCartTap ?? () {
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          cart.itemCount > 9 ? '9+' : '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 24, color: iconColor),
          onPressed: onNotificationTap,
        ),
      ],
    );
  }
}