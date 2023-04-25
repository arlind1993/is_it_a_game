import 'dart:math';
import 'dart:ui';
class LabColorSpace {

  LabColorSpace(this.l, this.a, this.b);

  final double l;
  final double a;
  final double b;

  @override
  String toString() {
    return "LAB(l: $l, a: $a, b: $b)";
  }
}

extension AdvancedColor on Color{


  static double _labApproximator(double input){
    return input > 0.008856
        ? pow(input, 1/3).toDouble()
        : 7.767 * input + 16/116;
  }
  static LabColorSpace convertRGBToLAB(Color input, {log_output = false}){
    final List<double> rgbFractional = [
      input.red / 255,
      input.green / 255,
      input.blue /255
    ];

    final List<double> srgbFractional = [
      100 * (rgbFractional[0] <= 0.04045
          ? rgbFractional[0] / 12
          : pow((rgbFractional[0] + 0.055) / 1.055, 2.4).toDouble()),
      100 * (rgbFractional[1] <= 0.04045
          ? rgbFractional[1] / 12
          : pow((rgbFractional[1] + 0.055) / 1.055, 2.4).toDouble()),
      100 * (rgbFractional[2] <= 0.04045
          ? rgbFractional[2] / 12
          : pow((rgbFractional[2] + 0.055) / 1.055, 2.4).toDouble()),
    ];


    final List<double> xyzTransform = [
      (0.4124564 * srgbFractional[0]) + (0.3575761 * srgbFractional[1]) + (0.1804375 * srgbFractional[2]),
      (0.2126729 * srgbFractional[0]) + (0.7151522 * srgbFractional[1]) + (0.0721750 * srgbFractional[2]),
      (0.0193339 * srgbFractional[0]) + (0.1191920 * srgbFractional[1]) + (0.9503041 * srgbFractional[2]),
    ];

    const xyzIlluminant = [
      95.047,
      100,
      108.883
    ];

    final List<double> xyzTransformIlluminated = [
      xyzTransform[0] / xyzIlluminant[0],
      xyzTransform[1] / xyzIlluminant[1],
      xyzTransform[2] / xyzIlluminant[2],
    ];


    LabColorSpace labResult = LabColorSpace(
      116 * _labApproximator(xyzTransformIlluminated[1]) - 16,
      500 * (_labApproximator(xyzTransformIlluminated[0])-_labApproximator(xyzTransformIlluminated[1])),
      200 * (_labApproximator(xyzTransformIlluminated[1])-_labApproximator(xyzTransformIlluminated[2])),
    );
    if(log_output){
      print("\x1B[33m $labResult \x1B[0m");
    }

    return labResult;
  }

  static double getEpsilon(Color color, Color other){
    LabColorSpace labColor = convertRGBToLAB(color);
    LabColorSpace labOther = convertRGBToLAB(other);
    return sqrt(pow(labColor.l - labOther.l, 2)
        + pow(labColor.a - labOther.a, 2)
        + pow(labColor.b - labOther.b, 2)
    );
  }

  static Color? getClosestColor(Color color, Iterable<Color> other){
    Color? closestColor;
    double closestEpsilon = double.infinity;
    for(Color element in other){
      double epsilon = getEpsilon(color, element);
      if(epsilon < closestEpsilon){
        closestColor = element;
        closestEpsilon = epsilon;
      }
    }
    return closestColor;
  }
}
