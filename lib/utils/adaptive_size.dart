import 'package:flutter/material.dart';

class AdaptiveSize {
  final BuildContext context;
  late double _screenWidth;
  late double _screenHeight;
  late double _blockSizeHorizontal;
  late double _blockSizeVertical;
  late double _scaleFactor;
  
  AdaptiveSize(this.context) {
    final size = MediaQuery.of(context).size;
    _screenWidth = size.width;
    _screenHeight = size.height;
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;
    _scaleFactor = _screenWidth / 375.0; // Base sur iPhone X comme référence
  }
  
  // Largeur en pourcentage de l'écran
  double w(double percentage) {
    return _blockSizeHorizontal * percentage;
  }
  
  // Hauteur en pourcentage de l'écran
  double h(double percentage) {
    return _blockSizeVertical * percentage;
  }
  
  // Taille de police adaptative
  double sp(double percentage) {
    // Taille de police adaptative basée sur une moyenne entre hauteur et largeur
    return ((_blockSizeHorizontal + _blockSizeVertical) / 2) * percentage;
  }
  
  // Pour garantir une taille minimale et maximale
  double size(double size, {double min = 0.8, double max = 1.2}) {
    return size * _scaleFactor.clamp(min, max);
  }
  
  // Padding adaptatif
  EdgeInsets padding({
    double horizontal = 0, 
    double vertical = 0,
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
    double all = 0,
    double factor = 1.0
  }) {
    if (all > 0) {
      return EdgeInsets.all(size(all * factor));
    }
    
    return EdgeInsets.fromLTRB(
      left > 0 ? size(left * factor) : size(horizontal * factor),
      top > 0 ? size(top * factor) : size(vertical * factor),
      right > 0 ? size(right * factor) : size(horizontal * factor),
      bottom > 0 ? size(bottom * factor) : size(vertical * factor),
    );
  }
  
  // Marge adaptative
  SizedBox gap({double width = 0, double height = 0}) {
    return SizedBox(
      width: width > 0 ? size(width) : null,
      height: height > 0 ? size(height) : null,
    );
  }
} 