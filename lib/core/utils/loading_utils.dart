
import 'package:flutter/material.dart';

class LoadingUtils {
  static OverlayEntry? _overlayEntry;

  static void showLoading(BuildContext context, bool isLoading) {
    if (!context.mounted) return;
    if (isLoading) {
      _showOverlay(context);
    } else {
      _hideOverlay();
    }
  }

  static void _showOverlay(BuildContext context) {
    _hideOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          const Opacity(
            opacity: 0.5,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
               // buildSpinKitSpinningLines(),
                //center circular
                const CircularProgressIndicator(
                  color: Colors.red,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // static Widget buildSpinKitSpinningLines() {
  //   return const SpinKitSpinningLines(
  //     color: AppColors.caribbeanGreen,
  //     size: 40.0,
  //     lineWidth: 3.0,
  //   );
  // }
  //
  // static Widget buildSpinKitSpinningLinesWhite() {
  //   return const SpinKitSpinningLines(
  //     color: AppColors.honeydew,
  //     size: 40.0,
  //     lineWidth: 3.0,
  //   );
  // }
}
