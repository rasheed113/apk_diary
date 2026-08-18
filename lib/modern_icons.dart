import 'package:flutter/material.dart';

/// Compatibility adapter for the app's existing icon3D/icon call sites.
/// It now renders the requested Material icon directly; it never converts
/// missing mappings into emoji or a blue-dot placeholder.
class Icon extends StatelessWidget {
  final IconData? icon;
  final double? size;
  final Color? color;
  final List<Shadow>? shadows;
  final String? semanticLabel;

  const Icon(this.icon,{super.key,this.size,this.color,this.shadows,this.semanticLabel,double? fill,double? weight,double? grade,double? opticalSize,TextDirection? textDirection,bool? applyTextScaling,BlendMode? blendMode,FontWeight? fontWeight});

  @override
  Widget build(BuildContext context) => _MaterialIcon(icon,size,color,shadows,semanticLabel);
}

class _MaterialIcon extends StatelessWidget {
  final IconData? data; final double? size; final Color? color; final List<Shadow>? shadows; final String? semanticLabel;
  const _MaterialIcon(this.data,this.size,this.color,this.shadows,this.semanticLabel);
  @override Widget build(BuildContext context) => Semantics(label:semanticLabel,image:true,child:IconTheme(data:IconThemeData(size:size,color:color,shadows:shadows),child:Icon(data)));
}
