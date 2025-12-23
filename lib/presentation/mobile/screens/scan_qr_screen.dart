import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/uri_parser.dart';
import '../../providers/totp_provider.dart';

class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({super.key});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner un code QR")),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          if (_isScanned) return;
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? rawValue = barcode.rawValue;
            if (rawValue != null) {
               _handleScan(rawValue);
               break; 
            }
          }
        },
        overlayBuilder: (context, constraints) {
             return Container(
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                     borderColor: Colors.red,
                     borderRadius: 10,
                     borderLength: 30,
                     borderWidth: 10,
                     cutOutSize: 300
                  ),
                ),
             );
        },
      ),
    );
  }

  void _handleScan(String uri) {
    setState(() {
      _isScanned = true;
    });
    try {
      final account = parseTotpUri(uri);
      ref.read(totpProvider.notifier).addAccount(account);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compte ajouté avec succès !")),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de scan: ${e.toString()}")),
      );
      setState(() {
        _isScanned = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// Helper class for overlay (Standard implementation often found in examples)
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;
  final double cutOutBottomOffset;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
    this.cutOutBottomOffset = 0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero)
      ..addRect(_getCutOutRect(rect));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }
  
  Rect _getCutOutRect(Rect rect) {
      final width = rect.width;
      final height = rect.height;
      final cutOutWidth = cutOutSize;
      final cutOutHeight = cutOutSize;
      final cutOutLeft = (width - cutOutWidth) / 2;
      final cutOutTop = (height - cutOutHeight) / 2 - cutOutBottomOffset;
      return Rect.fromLTWH(cutOutLeft, cutOutTop, cutOutWidth, cutOutHeight);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = _getCutOutRect(rect);

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Draw background with cutout
    final backgroundPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRect(cutOutRect);
    
    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw corners
    // Top left
    canvas.drawPath(
        Path()
          ..moveTo(cutOutRect.left, cutOutRect.top + borderLength)
          ..lineTo(cutOutRect.left, cutOutRect.top)
          ..lineTo(cutOutRect.left + borderLength, cutOutRect.top),
        borderPaint);
    // Top right
    canvas.drawPath(
        Path()
          ..moveTo(cutOutRect.right, cutOutRect.top + borderLength)
          ..lineTo(cutOutRect.right, cutOutRect.top)
          ..lineTo(cutOutRect.right - borderLength, cutOutRect.top),
        borderPaint);
    // Bottom left
    canvas.drawPath(
        Path()
          ..moveTo(cutOutRect.left, cutOutRect.bottom - borderLength)
          ..lineTo(cutOutRect.left, cutOutRect.bottom)
          ..lineTo(cutOutRect.left + borderLength, cutOutRect.bottom),
        borderPaint);
    // Bottom right
    canvas.drawPath(
        Path()
          ..moveTo(cutOutRect.right, cutOutRect.bottom - borderLength)
          ..lineTo(cutOutRect.right, cutOutRect.bottom)
          ..lineTo(cutOutRect.right - borderLength, cutOutRect.bottom),
        borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
      cutOutBottomOffset: cutOutBottomOffset,
    );
  }
}
