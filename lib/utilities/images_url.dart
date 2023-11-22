import '/utilities/constants.dart';

String heroLevelImage(String heroId, int level) {
  return '$baseImageUrl/heroes/$heroId/$level.png';
}

String heroSkinImage(String heroId, String skinId) {
  return '$baseImageUrl/heroes/$heroId/$skinId/hero.png';
}

String heroSkinLevelImage(String heroId, String skinId, int level) {
  return '$baseImageUrl/heroes/$heroId/$skinId/$level.png';
}

String bossImage(String image) {
  return 'assets/images/bosses/$image';
}

String bloonImage(String image) {
  return 'assets/images/bloons/$image';
}

String minionImage(String image) {
  return 'assets/images/minions/$image';
}

String mapImage(String image) {
  return 'assets/images/maps/$image';
}

String towerImage(String image) {
  return 'assets/images/towers/$image';
}

String heroImage(String image) {
  return 'assets/images/heroes/$image';
}

String heroLvlImage(String baseImage, String level) {
  if (int.parse(level) == 1) {
    return heroImage(baseImage);
  }
  String imageNameWithoutExtension =
      baseImage.substring(0, baseImage.length - 4);
  return 'assets/images/heroes/${imageNameWithoutExtension}lvl$level.png';
}
