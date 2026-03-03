/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/icon-no-bg.png
  AssetGenImage get iconNoBg =>
      const AssetGenImage('assets/icons/icon-no-bg.png');

  /// File path: assets/icons/icon.png
  AssetGenImage get icon => const AssetGenImage('assets/icons/icon.png');

  /// List of all assets
  List<AssetGenImage> get values => [iconNoBg, icon];
}

class $AssetsSvgsGen {
  const $AssetsSvgsGen();

  /// File path: assets/svgs/businessIcon.svg
  String get businessIcon => 'assets/svgs/businessIcon.svg';

  /// File path: assets/svgs/contactIcon.svg
  String get contactIcon => 'assets/svgs/contactIcon.svg';

  /// File path: assets/svgs/emailIcon.svg
  String get emailIcon => 'assets/svgs/emailIcon.svg';

  /// File path: assets/svgs/eventIcon.svg
  String get eventIcon => 'assets/svgs/eventIcon.svg';

  /// File path: assets/svgs/generateIcon.svg
  String get generateIcon => 'assets/svgs/generateIcon.svg';

  /// File path: assets/svgs/historyIcon.svg
  String get historyIcon => 'assets/svgs/historyIcon.svg';

  /// File path: assets/svgs/instagramIcon.svg
  String get instagramIcon => 'assets/svgs/instagramIcon.svg';

  /// File path: assets/svgs/locationIcon.svg
  String get locationIcon => 'assets/svgs/locationIcon.svg';

  /// File path: assets/svgs/scanIcon.svg
  String get scanIcon => 'assets/svgs/scanIcon.svg';

  /// File path: assets/svgs/telephoneIcon.svg
  String get telephoneIcon => 'assets/svgs/telephoneIcon.svg';

  /// File path: assets/svgs/textIcon.svg
  String get textIcon => 'assets/svgs/textIcon.svg';

  /// File path: assets/svgs/twitterIcon.svg
  String get twitterIcon => 'assets/svgs/twitterIcon.svg';

  /// File path: assets/svgs/websiteIcon.svg
  String get websiteIcon => 'assets/svgs/websiteIcon.svg';

  /// File path: assets/svgs/whatsappIcon.svg
  String get whatsappIcon => 'assets/svgs/whatsappIcon.svg';

  /// File path: assets/svgs/wifiIcon.svg
  String get wifiIcon => 'assets/svgs/wifiIcon.svg';

  /// List of all assets
  List<String> get values => [
    businessIcon,
    contactIcon,
    emailIcon,
    eventIcon,
    generateIcon,
    historyIcon,
    instagramIcon,
    locationIcon,
    scanIcon,
    telephoneIcon,
    textIcon,
    twitterIcon,
    websiteIcon,
    whatsappIcon,
    wifiIcon,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsSvgsGen svgs = $AssetsSvgsGen();
  static const String shorebird = 'shorebird.yaml';

  /// List of all assets
  static List<String> get values => [shorebird];
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
