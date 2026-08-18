import 'package:flutter/material.dart' as material;

/// Compatibility adapter for the app's existing icon call sites.
/// Renders the requested Material icon directly; no emoji or dot fallback.
class Icon extends material.StatelessWidget {
  final material.IconData? icon;
  final double? size;
  final material.Color? color;
  final List<material.Shadow>? shadows;
  final String? semanticLabel;

  const Icon(this.icon,{super.key,this.size,this.color,this.shadows,this.semanticLabel,double? fill,double? weight,double? grade,double? opticalSize,material.TextDirection? textDirection,bool? applyTextScaling,material.BlendMode? blendMode,material.FontWeight? fontWeight});

  @override material.Widget build(material.BuildContext context) => material.Icon(icon,size:size,color:color,shadows:shadows,semanticLabel:semanticLabel);
}
