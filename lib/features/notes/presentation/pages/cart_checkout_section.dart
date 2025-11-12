import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../controller/cart_controller.dart';
import 'package:provider/provider.dart';

class CartCheckoutSection extends StatelessWidget {
  final double userPoints;
  final double pointsToRedeem;
  final bool isLoadingPoints;
  final bool isProcessing;
  final Function(double) onPointsChanged;
  final Function(double) onCheckout;

  const CartCheckoutSection({
    super.key,
    required this.userPoints,
    required this.pointsToRedeem,
    required this.isLoadingPoints,
    required this.isProcessing,
    required this.onPointsChanged,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final maxPoints = userPoints > cart.subtotal ? cart.subtotal : userPoints;
    final finalAmount = cart.subtotal - pointsToRedeem;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLoadingPoints && userPoints > 0)
                _PointsRedeemCard(
                  userPoints: userPoints,
                  pointsToRedeem: pointsToRedeem,
                  maxPoints: maxPoints,
                  onChanged: onPointsChanged,
                ),
              _PriceRow('Subtotal', cart.subtotal),
              if (pointsToRedeem > 0)
                _PriceRow('Points Redeemed', -pointsToRedeem, color: AppColors.success),
              const Divider(height: 24),
              _PriceRow('Total to Pay', finalAmount, isTotal: true),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : () => onCheckout(finalAmount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Checkout • ₹${finalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointsRedeemCard extends StatelessWidget {
  final double userPoints;
  final double pointsToRedeem;
  final double maxPoints;
  final Function(double) onChanged;

  const _PointsRedeemCard({
    required this.userPoints,
    required this.pointsToRedeem,
    required this.maxPoints,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Redeem Points (1 point = ₹1)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${userPoints.toStringAsFixed(0)} pts',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: pointsToRedeem,
            min: 0,
            max: maxPoints,
            divisions: maxPoints > 0 ? maxPoints.toInt() : 1,
            label: '₹${pointsToRedeem.toStringAsFixed(0)}',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;
  final Color? color;

  const _PriceRow(this.label, this.amount, {this.isTotal = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 18 : 15,
              color: color,
            )),
        Text(
          '${amount >= 0 ? '' : '-'}₹${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            fontSize: isTotal ? 20 : 16,
            color: color ?? (isTotal ? AppColors.primary : null),
          ),
        ),
      ],
    );
  }
}
