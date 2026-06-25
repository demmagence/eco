// Utility: pad the source logo onto a larger transparent square canvas so the
// launcher icon has breathing room (the raw logo fills the whole frame and
// looks zoomed/cropped inside Android's adaptive-icon safe zone).
//
// Usage: dart run tool/pad_logo.dart
//
// Reads assets/images/logo.png and writes assets/images/logo_padded.png where
// the logo occupies `contentRatio` of the canvas, centered.
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Fraction of the canvas the logo content should occupy. Android's adaptive
  // safe zone is ~66% of the icon; 0.64 keeps the whole logo comfortably inside.
  const contentRatio = 0.64;

  final src = img.decodePng(File('assets/images/logo.png').readAsBytesSync());
  if (src == null) {
    stderr.writeln('Could not decode assets/images/logo.png');
    exit(1);
  }

  // Square canvas sized so the (square) logo lands at contentRatio.
  final logoSide = src.width > src.height ? src.width : src.height;
  final canvasSide = (logoSide / contentRatio).round();
  final offset = ((canvasSide - logoSide) / 2).round();

  final canvas = img.Image(
    width: canvasSide,
    height: canvasSide,
    numChannels: 4,
  );
  // Fully transparent background.
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));
  img.compositeImage(canvas, src, dstX: offset, dstY: offset);

  File('assets/images/logo_padded.png')
      .writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln(
    'Wrote assets/images/logo_padded.png '
    '(${canvasSide}x$canvasSide, logo at ${(contentRatio * 100).round()}%)',
  );
}
